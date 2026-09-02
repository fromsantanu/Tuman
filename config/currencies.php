<?php
declare(strict_types=1);

/**
 * Supported ISO 4217 currencies and ISO 3166-1 alpha-2 countries.
 * Extend either map here; database columns deliberately store only the codes.
 */
const TUMAN_CURRENCIES = [
    'INR' => 'Indian Rupee', 'USD' => 'US Dollar', 'EUR' => 'Euro', 'GBP' => 'Pound Sterling',
    'AUD' => 'Australian Dollar', 'CAD' => 'Canadian Dollar', 'AED' => 'UAE Dirham', 'SGD' => 'Singapore Dollar',
    'NZD' => 'New Zealand Dollar', 'ZAR' => 'South African Rand', 'JPY' => 'Japanese Yen', 'CNY' => 'Chinese Yuan',
    'HKD' => 'Hong Kong Dollar', 'CHF' => 'Swiss Franc', 'SEK' => 'Swedish Krona', 'NOK' => 'Norwegian Krone',
    'DKK' => 'Danish Krone', 'BDT' => 'Bangladeshi Taka', 'LKR' => 'Sri Lankan Rupee', 'NPR' => 'Nepalese Rupee',
];

const TUMAN_COUNTRIES = [
    'AU' => 'Australia', 'BD' => 'Bangladesh', 'CA' => 'Canada', 'CH' => 'Switzerland', 'CN' => 'China',
    'DK' => 'Denmark', 'GB' => 'United Kingdom', 'HK' => 'Hong Kong', 'IN' => 'India', 'JP' => 'Japan',
    'LK' => 'Sri Lanka', 'NO' => 'Norway', 'NP' => 'Nepal', 'NZ' => 'New Zealand', 'SG' => 'Singapore',
    'SE' => 'Sweden', 'US' => 'United States', 'ZA' => 'South Africa', 'AE' => 'United Arab Emirates',
];

function tuman_currency_code(string $value): ?string
{
    $value = strtoupper(trim($value));
    return isset(TUMAN_CURRENCIES[$value]) ? $value : null;
}

function tuman_country_code(string $value): ?string
{
    $value = strtoupper(trim($value));
    return isset(TUMAN_COUNTRIES[$value]) ? $value : null;
}

function tuman_currency_amount_label(string $amount, string $currencyCode): string
{
    $currencyCode = tuman_currency_code($currencyCode) ?? 'INR';
    [$whole, $fraction] = array_pad(explode('.', $amount, 2), 2, '00');
    $whole = preg_replace('/\B(?=(\d{3})+(?!\d))/', ',', $whole) ?? $whole;
    return $currencyCode . ' ' . $whole . '.' . str_pad(substr($fraction, 0, 2), 2, '0');
}
