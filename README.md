# Tippiti PHP Client

Official PHP client for the [Tippiti](https://tippiti.io) API – the transcription and dictation platform for physicians, attorneys, forensic examiners and professional typing services.

- **Interactive API docs:** [apidocs.tippiti.io](https://apidocs.tippiti.io)
- **OpenAPI specification:** [tippiti/openapi](https://github.com/tippiti/openapi)
- **Platform:** [tippiti.io](https://tippiti.io)
- **Support:** [app.tippiti.io/support/create](https://app.tippiti.io/support/create)

Framework-agnostic. Built on [Guzzle](https://docs.guzzlephp.org/) and PSR-7 / PSR-18. Runs in Laravel, Symfony, Slim or plain PHP.

## Installation

```bash
composer require tippiti/api-client
```

Requires PHP 8.1 or newer. Pulls Guzzle as its default HTTP client.

## Quick start

```php
use Tippiti\Api\Tippiti;
use Tippiti\Api\Generated\Api\DictationApi;

$config = Tippiti::configure(token: getenv('TIPPITI_TOKEN'));
$dictations = new DictationApi(config: $config);

$response = $dictations->dictationIndex(include_notes: true);

foreach ($response->getData() as $dictation) {
    echo $dictation->getId() . ': ' . $dictation->getTitle() . PHP_EOL;
}
```

Every endpoint, request body, parameter and response is typed, derived directly from the OpenAPI specification at [apidocs.tippiti.io](https://apidocs.tippiti.io).

## Authentication

`Tippiti::configure()` configures Bearer-token authentication against `https://app.tippiti.io/api`. Tokens are scoped to the issuing user's permissions (main user or sub-user with the relevant capabilities) and can be created in the account settings.

## Resource IDs

All resource identifiers are sqid-encoded strings prefixed with `aid-`, for example `aid-xyz12345`. Model properties reflect this – IDs are typed `string`, never `int`:

```php
$dictation = $dictations->dictationShow(dictation: 'aid-xyz12345');
```

Raw integer IDs are rejected with a `404` response.

## Available Api classes

After installation, every API group has a dedicated class under `Tippiti\Api\Generated\Api\*Api`:

```php
use Tippiti\Api\Generated\Api\DictationApi;
use Tippiti\Api\Generated\Api\AccountApi;
use Tippiti\Api\Generated\Api\FolderApi;
use Tippiti\Api\Generated\Api\InstructionSetApi;
use Tippiti\Api\Generated\Api\SubUserApi;
// ...
```

Method names follow the operationIds from the specification: `dictationIndex`, `dictationStore`, `dictationShow`, `folderIndex`, `accountUpdate` and so on. See [apidocs.tippiti.io](https://apidocs.tippiti.io) for the full operation list.

## Response envelope

Successful responses expose `getSuccess(): bool` and `getData(): mixed` accessors. Failure responses throw `Tippiti\Api\Generated\ApiException` containing the HTTP status code, the decoded response body and the response headers. Validation failures produce `ApiException` with status `422` and per-field error messages. Rate-limit breaches produce `ApiException` with status `429` and a `Retry-After` header.

```php
use Tippiti\Api\Generated\ApiException;

try {
    $response = $dictations->dictationShow(dictation: 'aid-xyz12345');
} catch (ApiException $e) {
    fwrite(STDERR, "HTTP {$e->getCode()}: {$e->getMessage()}\n");
    print_r($e->getResponseBody());
}
```

## Custom base URL

```php
$config = Tippiti::configure(
    token: '...',
    baseUrl: 'https://staging.app.tippiti.io/api',
);
```

## Custom HTTP client

Pass your own Guzzle-compatible client to any Api constructor – useful for custom timeouts, proxies, HTTP/2 tuning, or middleware:

```php
use GuzzleHttp\Client;
use GuzzleHttp\HandlerStack;

$stack = HandlerStack::create();
// add your middleware
$http = new Client(['handler' => $stack, 'timeout' => 30]);

$dictations = new DictationApi(client: $http, config: $config);
```

## Versioning

This client follows [Semantic Versioning](https://semver.org). A release note in [CHANGELOG.md](CHANGELOG.md) accompanies every version. Breaking changes to the underlying API produce a major version bump of this package.

## License

[MIT](LICENSE). The Tippiti platform, trademarks and data are not covered by this license.
