#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QFontDatabase>
#include <QStandardPaths>
#include <QUrl>
#include <QtQml/qqml.h>
#include "AppCatalog.h"
#include "AppInstaller.h"
#include "AppRegistry.h"
#include "AppRunner.h"
#include "NetworkReply.h"
#include "PackageDownloader.h"
#include "SecureStorageReply.h"

#ifndef EXAMPLES_PATH
#define EXAMPLES_PATH ""
#endif

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

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
    auto storeBaseUrl = QUrl(QStringLiteral("http://localhost:8080"));
    PackageDownloader downloader(&installer, storeBaseUrl, storageRoot);
    auto catalogUrl = storeBaseUrl.resolved(QUrl(QStringLiteral("/api/catalog")));
    AppCatalog catalog(catalogUrl);

    auto *ctx = engine.rootContext();
    ctx->setContextProperty(QStringLiteral("appRunner"), &runner);
    ctx->setContextProperty(QStringLiteral("appRegistry"), &registry);
    ctx->setContextProperty(QStringLiteral("installedAppsModel"), registry.model());
    ctx->setContextProperty(QStringLiteral("appInstaller"), &installer);
    ctx->setContextProperty(QStringLiteral("packageDownloader"), &downloader);
    ctx->setContextProperty(QStringLiteral("appCatalog"), &catalog);
    ctx->setContextProperty(QStringLiteral("installDir"), installDir);
    ctx->setContextProperty(QStringLiteral("examplesPath"),
                            QStringLiteral(EXAMPLES_PATH));

    // Seed registry with example apps (adds any missing examples)
    {
        auto exPath = QStringLiteral(EXAMPLES_PATH);
        if (!exPath.isEmpty()) {
            struct { const char *dir; const char *name; const char *icon;
                     const char *color; const char *id; } examples[] = {
                { "hello-world", "Hello World", "\ue9b2", "#2196F3", "com.squared.helloworld" },
                { "counter", "Counter", "\ue145", "#9C27B0", "com.squared.counter" },
                { "todo", "Todo", "\ue614", "#FF9800", "com.squared.todo" },
                { "finance", "Finance", "\ue850", "#22C55E", "com.squared.finance" },
                { "weather", "Weather", "\ue430", "#42A5F5", "com.squared.weather" },
            };
            for (const auto &ex : examples) {
                auto id = QString::fromLatin1(ex.id);
                if (registry.findApp(id))
                    continue;
                AppEntry entry;
                entry.id = id;
                entry.name = QString::fromLatin1(ex.name);
                entry.version = QStringLiteral("1.0.0");
                entry.icon = QString::fromUtf8(ex.icon);
                entry.color = QString::fromLatin1(ex.color);
                entry.dirName = QString::fromLatin1(ex.dir);
                entry.installDate = QDateTime::currentDateTime();
                registry.addApp(entry);
            }
        }
    }

    engine.loadFromModule("Squared.Host", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
