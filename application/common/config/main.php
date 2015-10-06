<?php
/**
 * Get config settings from ENV vars or set defaults
 */
$MYSQL_HOST = getenv('MYSQL_HOST') ?: 'localhost';
$MYSQL_DATABASE = getenv('MYSQL_DATABASE') ?: 'example';
$MYSQL_USER = getenv('MYSQL_USER') ?: 'example';
$MYSQL_PASSWORD = getenv('MYSQL_PASSWORD') ?: 'example';
$TEST_MYSQL_HOST = getenv('TEST_MYSQL_HOST') ?: 'localhost';
$TEST_MYSQL_DATABASE = getenv('TEST_MYSQL_DATABASE') ?: 'example';
$TEST_MYSQL_USER = getenv('TEST_MYSQL_USER') ?: 'example';
$TEST_MYSQL_PASSWORD = getenv('TEST_MYSQL_PASSWORD') ?: 'example';
$ADMIN_EMAIL = getenv('ADMIN_EMAIL') ?: 'nobody@nowhere.com';
$APP_ENV = getenv('APP_ENV') ?: "not set";

return [
    'vendorPath' => dirname(dirname(__DIR__)) . '/vendor',
    'components' => [
        'cache' => [
            'class' => 'yii\caching\FileCache',
        ],
        "db" => [
            'class' => 'yii\db\Connection',
            "dsn" => "mysql:host=$MYSQL_HOST;dbname=$MYSQL_DATABASE",
            "username" => $MYSQL_USER,
            "password" => $MYSQL_PASSWORD,
            'charset' => 'utf8',
            'emulatePrepare' => false,
            'tablePrefix' => '',
        ],
        "testDb" => [
            "class" => 'yii\db\Connection',
            "dsn" => "mysql:host=$TEST_MYSQL_HOST;dbname=$TEST_MYSQL_DATABASE",
            "username" => $TEST_MYSQL_USER,
            "password" => $TEST_MYSQL_PASSWORD,
            "emulatePrepare" => false,
            "charset" => "utf8",
            "tablePrefix" => "",
        ],
        'log' => [
            'traceLevel' => 0,
            'targets' => [
                [
                    'class' => 'Sil\JsonSyslog\JsonSyslogTarget',
                    'levels' => ['error', 'warning'],
                    'except' => [
                        'yii\web\HttpException:401',
                        'yii\web\HttpException:404',
                    ],
                    'logVars' => [], // Disable logging of _SERVER, _POST, etc.
                    'prefix' => function($message) use ($APP_ENV) {
                        $prefixData = array(
                            'env' => $APP_ENV,
                        );
                        if (! \Yii::$app->user->isGuest) {
                            $prefixData['user'] = \Yii::$app->user->identity->email;
                        }
                        return \yii\helpers\Json::encode($prefixData);
                    },
                ],
            ],
        ],
    ],
    'params' => [
        'adminEmail' => $ADMIN_EMAIL,
        'appEnv' => $APP_ENV,
    ],
];
