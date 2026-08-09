<?php

require __DIR__ . '/../vendor/autoload.php';

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Factory\AppFactory;

$app = AppFactory::create();

$startTime = microtime(true);

$app->addRoutingMiddleware();
$app->addErrorMiddleware(true, true, true);

$app->get('/', function (Request $request, Response $response) {
    $data = [
        'message' => 'Welcome to your PHP API',
        'version' => '1.0.0',
        'endpoints' => [
            'health' => '/health',
            'root' => '/'
        ]
    ];
    $response->getBody()->write(json_encode($data));
    return $response->withHeader('Content-Type', 'application/json');
});

$app->get('/health', function (Request $request, Response $response) use ($startTime) {
    $data = [
        'status' => 'healthy',
        'timestamp' => gmdate('Y-m-d\TH:i:s\Z'),
        'uptime' => microtime(true) - $startTime
    ];
    $response->getBody()->write(json_encode($data));
    return $response->withHeader('Content-Type', 'application/json');
});

$app->run();
