INSERT INTO apps (id, name, version, author, description, icon_url, package_url, size_bytes, category)
VALUES
    ('com.squared.helloworld', 'Hello World', '1.0.0', 'Squared Computing',
     'A simple hello world app',
     '', '',
     8192, 'examples'),
    ('com.squared.counter', 'Counter', '1.0.0', 'Squared Computing',
     'A simple counter app',
     '', '',
     12288, 'examples'),
    ('com.squared.todo', 'Todo', '1.0.0', 'Squared Computing',
     'A simple todo list',
     '', '',
     24576, 'productivity'),
    ('com.squared.finance', 'Finance Tracker', '1.0.0', 'Squared Computing',
     'Track income and expenses',
     '', '',
     32768, 'finance'),
    ('com.squared.weather', 'Weather', '1.0.0', 'Squared Computing',
     'Live weather using SecureStorage + Network',
     '', '',
     16384, 'utilities')
ON CONFLICT (id) DO NOTHING;
