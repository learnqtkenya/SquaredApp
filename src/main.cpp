#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCommandLineParser>
#include <QDir>
#include <QFileInfo>
#include <QFontDatabase>
#include <QIcon>
#include <QQuickStyle>
#include <QStandardPaths>
#include <QTimer>
#include <QUrl>
#include <QtQml/qqml.h>
#include "AppCatalog.h"
#include "AppInstaller.h"
#include "AppManifest.h"
#include "AppRegistry.h"
#include "AppRunner.h"
#include "FileSystemWatcher.h"
#include "NetworkReply.h"
#include "PackageDownloader.h"
#include "SecureStorageReply.h"
#include "config.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName(QStringLiteral("Squared"));
    app.setApplicationName(QStringLiteral("Squared"));
    app.setApplicationVersion(QString::fromUtf8(config::project_version.data(),
                                                config::project_version.size()));

    app.setWindowIcon(QIcon(QStringLiteral(":/icons/squared-512.png")));


    QQuickStyle::setStyle(QStringLiteral("Basic"));

    QCommandLineParser parser;
    parser.setApplicationDescription(QStringLiteral("Squared \u2014 QML super app runtime"));
    parser.addHelpOption();
    parser.addVersionOption();

    QCommandLineOption devOption(
        QStringLiteral("dev"),
        QStringLiteral("Launch a single app in dev mode with hot reload."),
        QStringLiteral("path"));
    parser.addOption(devOption);

    parser.process(app);

    bool devMode = parser.isSet(devOption);
    auto devAppPath = devMode
        ? QFileInfo(parser.value(devOption)).absoluteFilePath()
        : QString();

    QFontDatabase::addApplicationFont(
        QStringLiteral(":/qt/qml/Squared/UI/fonts/Inter-Variable.ttf"));
    QFontDatabase::addApplicationFont(
        QStringLiteral(":/qt/qml/Squared/UI/fonts/MaterialSymbolsOutlined-Variable.ttf"));

    QQmlApplicationEngine engine;

    qmlRegisterUncreatableType<SecureStorageReply>("Squared.SDK", 1, 0,
        "SecureStorageReply", QStringLiteral("Created by SecureStorage"));
    qmlRegisterUncreatableType<NetworkReply>("Squared.SDK", 1, 0,
        "NetworkReply", QStringLiteral("Created by NetworkClient"));

    auto appDataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    auto storageRoot = appDataDir + QStringLiteral("/storage");
    auto installDir = appDataDir + QStringLiteral("/apps");
    auto registryPath = appDataDir + QStringLiteral("/registry.dat");

    QDir().mkpath(installDir);

    AppRunner runner(&engine, storageRoot);
    AppRegistry registry(registryPath);
    AppInstaller installer;
    auto storeBaseUrl = QUrl(qEnvironmentVariable(
        "SQUARED_STORE_URL", QString::fromUtf8(config::store_url.data(), config::store_url.size())));
    PackageDownloader downloader(&installer, storeBaseUrl, storageRoot);
    auto storeUrlStr = storeBaseUrl.toString();
    if (!storeUrlStr.endsWith(QLatin1Char('/')))
        storeUrlStr.append(QLatin1Char('/'));
    auto catalogUrl = QUrl(storeUrlStr + QStringLiteral("api/catalog"));
    AppCatalog catalog(catalogUrl);

    // Register downloaded app in registry after successful install
    // Uses catalog metadata for icon/color when available
    QObject::connect(&downloader, &PackageDownloader::installed,
                     [&registry, &catalog, &installDir](const QString &appId) {
        auto manifest = AppManifest::fromDirectory(installDir + QStringLiteral("/") + appId);
        if (!manifest) return;
        AppEntry entry;
        entry.id = manifest->id;
        entry.name = manifest->name;
        entry.version = manifest->version;
        entry.author = manifest->author;
        entry.description = manifest->description;
        entry.dirName = appId;
        entry.icon = QStringLiteral("\ue5c3");
        entry.color = QStringLiteral("#2196F3");

        // Try to get icon/color from catalog
        for (const auto &ce : catalog.entries()) {
            auto map = ce.toMap();
            if (map.value(QStringLiteral("id")).toString() == appId) {
                auto icon = map.value(QStringLiteral("icon")).toString();
                auto color = map.value(QStringLiteral("color")).toString();
                if (!icon.isEmpty()) entry.icon = icon;
                if (!color.isEmpty()) entry.color = color;
                break;
            }
        }

        entry.installDate = QDateTime::currentDateTime();
        registry.addApp(entry);
    });

    auto *ctx = engine.rootContext();
    ctx->setContextProperty(QStringLiteral("appRunner"), &runner);
    ctx->setContextProperty(QStringLiteral("appRegistry"), &registry);
    ctx->setContextProperty(QStringLiteral("installedAppsModel"), registry.model());
    ctx->setContextProperty(QStringLiteral("appInstaller"), &installer);
    ctx->setContextProperty(QStringLiteral("packageDownloader"), &downloader);
    ctx->setContextProperty(QStringLiteral("appCatalog"), &catalog);
    ctx->setContextProperty(QStringLiteral("installDir"), installDir);
    ctx->setContextProperty(QStringLiteral("storageRoot"), storageRoot);
    // Resolve examples path: prefer compile-time path (dev builds), fall back
    // to installed location relative to executable (AppImage, packages, etc.)
    auto configExamplesPath = QString::fromUtf8(config::examples_path.data(), config::examples_path.size());
    QString examplesPathResolved;
    if (QDir(configExamplesPath).exists()) {
        examplesPathResolved = configExamplesPath;
    } else {
        auto appDir = QCoreApplication::applicationDirPath();
        // Linux/macOS installed: <prefix>/bin/Squared → <prefix>/share/squared/examples/apps
        auto installed = appDir + QStringLiteral("/../share/squared/examples/apps");
        if (QDir(installed).exists())
            examplesPathResolved = QFileInfo(installed).absoluteFilePath();
    }
    ctx->setContextProperty(QStringLiteral("examplesPath"), examplesPathResolved);

    // Hot reload objects — must outlive the if/else block to survive into app.exec()
    FileSystemWatcher watcher;
    QTimer reloadTimer;

    if (devMode) {
        ctx->setContextProperty(QStringLiteral("devAppPath"), devAppPath);

        watcher.addDirectory(devAppPath);
        reloadTimer.setSingleShot(true);
        reloadTimer.setInterval(200);

        QObject::connect(&watcher, &FileSystemWatcher::fileChanged,
                         &reloadTimer, qOverload<>(&QTimer::start));

        QObject::connect(&reloadTimer, &QTimer::timeout, [&]() {
            qInfo() << "File changed — reloading...";
            runner.close();
            engine.clearComponentCache();
            emit runner.reloadRequested();
        });

        engine.loadFromModule("Squared.Host", "DevWindow");
    } else {
        engine.loadFromModule("Squared.Host", "Main");
    }

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
