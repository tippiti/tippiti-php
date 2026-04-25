<?php

declare(strict_types=1);

namespace Tippiti\Api;

use Tippiti\Api\Generated\Configuration;

/**
 * Entry point for the Tippiti PHP client.
 *
 * All resource IDs used with this client are sqid-encoded strings prefixed
 * with `aid-` (for example `aid-xyz12345`). Raw integer IDs are rejected
 * with a 404 response by the server.
 */
final class Tippiti
{
    public const DEFAULT_BASE_URL = 'https://app.tippiti.io/api';

    /**
     * Build a configured `Configuration` object for use with any of the
     * generated Api classes (DictationApi, AccountApi, FolderApi, …).
     */
    public static function configure(
        string $token,
        string $baseUrl = self::DEFAULT_BASE_URL,
    ): Configuration {
        return (new Configuration())
            ->setAccessToken($token)
            ->setHost($baseUrl);
    }
}
