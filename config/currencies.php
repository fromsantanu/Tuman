<?php
declare(strict_types=1);

/**
 * Supported ISO 4217 currencies and ISO 3166-1 alpha-2 countries.
 * Extend either map here; database columns deliberately store only the codes.
 */
const TUMAN_CURRENCIES = [
    'INR' => 'Indian Rupee', 'USD' => 'US Dollar', 'EUR' => 'Euro', 'GBP' => 'Pound Sterling',
    'AUD' => 'Australian Dollar', 'CAD' => 'Canadian Dollar', 'CHF' => 'Swiss Franc', 'JPY' => 'Japanese Yen',
    'CNY' => 'Chinese Yuan', 'HKD' => 'Hong Kong Dollar', 'KRW' => 'South Korean Won', 'SGD' => 'Singapore Dollar',
    'TWD' => 'New Taiwan Dollar', 'THB' => 'Thai Baht', 'MYR' => 'Malaysian Ringgit', 'IDR' => 'Indonesian Rupiah',
    'PHP' => 'Philippine Peso', 'VND' => 'Vietnamese Dong', 'AED' => 'UAE Dirham', 'SAR' => 'Saudi Riyal',
    'QAR' => 'Qatari Riyal', 'KWD' => 'Kuwaiti Dinar', 'ILS' => 'Israeli New Shekel', 'TRY' => 'Turkish Lira',
    'ZAR' => 'South African Rand', 'EGP' => 'Egyptian Pound', 'NGN' => 'Nigerian Naira', 'KES' => 'Kenyan Shilling',
    'BRL' => 'Brazilian Real', 'MXN' => 'Mexican Peso', 'ARS' => 'Argentine Peso', 'CLP' => 'Chilean Peso',
    'COP' => 'Colombian Peso', 'PEN' => 'Peruvian Sol', 'NZD' => 'New Zealand Dollar', 'SEK' => 'Swedish Krona',
    'NOK' => 'Norwegian Krone', 'DKK' => 'Danish Krone', 'PLN' => 'Polish Zloty', 'CZK' => 'Czech Koruna',
    'HUF' => 'Hungarian Forint', 'RON' => 'Romanian Leu', 'UAH' => 'Ukrainian Hryvnia', 'RUB' => 'Russian Ruble',
    'BDT' => 'Bangladeshi Taka', 'LKR' => 'Sri Lankan Rupee', 'NPR' => 'Nepalese Rupee', 'PKR' => 'Pakistani Rupee',
];

const TUMAN_COUNTRIES = [
    'AF' => 'Afghanistan', 'AL' => 'Albania', 'DZ' => 'Algeria', 'AD' => 'Andorra', 'AO' => 'Angola',
    'AG' => 'Antigua and Barbuda', 'AR' => 'Argentina', 'AM' => 'Armenia', 'AU' => 'Australia', 'AT' => 'Austria',
    'AZ' => 'Azerbaijan', 'BS' => 'Bahamas', 'BH' => 'Bahrain', 'BD' => 'Bangladesh', 'BB' => 'Barbados',
    'BY' => 'Belarus', 'BE' => 'Belgium', 'BZ' => 'Belize', 'BJ' => 'Benin', 'BT' => 'Bhutan',
    'BO' => 'Bolivia', 'BA' => 'Bosnia and Herzegovina', 'BW' => 'Botswana', 'BR' => 'Brazil', 'BN' => 'Brunei',
    'BG' => 'Bulgaria', 'BF' => 'Burkina Faso', 'BI' => 'Burundi', 'CV' => 'Cabo Verde', 'KH' => 'Cambodia',
    'CM' => 'Cameroon', 'CA' => 'Canada', 'CF' => 'Central African Republic', 'TD' => 'Chad', 'CL' => 'Chile',
    'CN' => 'China', 'CO' => 'Colombia', 'KM' => 'Comoros', 'CG' => 'Congo', 'CD' => 'Congo, Democratic Republic of the',
    'CR' => 'Costa Rica', 'CI' => "Cote d'Ivoire", 'HR' => 'Croatia', 'CU' => 'Cuba', 'CY' => 'Cyprus',
    'CZ' => 'Czechia', 'DK' => 'Denmark', 'DJ' => 'Djibouti', 'DM' => 'Dominica', 'DO' => 'Dominican Republic',
    'EC' => 'Ecuador', 'EG' => 'Egypt', 'SV' => 'El Salvador', 'GQ' => 'Equatorial Guinea', 'ER' => 'Eritrea',
    'EE' => 'Estonia', 'SZ' => 'Eswatini', 'ET' => 'Ethiopia', 'FJ' => 'Fiji', 'FI' => 'Finland',
    'FR' => 'France', 'GA' => 'Gabon', 'GM' => 'Gambia', 'GE' => 'Georgia', 'DE' => 'Germany',
    'GH' => 'Ghana', 'GR' => 'Greece', 'GD' => 'Grenada', 'GT' => 'Guatemala', 'GN' => 'Guinea',
    'GW' => 'Guinea-Bissau', 'GY' => 'Guyana', 'HT' => 'Haiti', 'HN' => 'Honduras', 'HU' => 'Hungary',
    'IS' => 'Iceland', 'IN' => 'India', 'ID' => 'Indonesia', 'IR' => 'Iran', 'IQ' => 'Iraq',
    'IE' => 'Ireland', 'IL' => 'Israel', 'IT' => 'Italy', 'JM' => 'Jamaica', 'JP' => 'Japan',
    'JO' => 'Jordan', 'KZ' => 'Kazakhstan', 'KE' => 'Kenya', 'KI' => 'Kiribati', 'KP' => 'North Korea',
    'KR' => 'South Korea', 'KW' => 'Kuwait', 'KG' => 'Kyrgyzstan', 'LA' => 'Laos', 'LV' => 'Latvia',
    'LB' => 'Lebanon', 'LS' => 'Lesotho', 'LR' => 'Liberia', 'LY' => 'Libya', 'LI' => 'Liechtenstein',
    'LT' => 'Lithuania', 'LU' => 'Luxembourg', 'MG' => 'Madagascar', 'MW' => 'Malawi', 'MY' => 'Malaysia',
    'MV' => 'Maldives', 'ML' => 'Mali', 'MT' => 'Malta', 'MH' => 'Marshall Islands', 'MR' => 'Mauritania',
    'MU' => 'Mauritius', 'MX' => 'Mexico', 'FM' => 'Micronesia', 'MD' => 'Moldova', 'MC' => 'Monaco',
    'MN' => 'Mongolia', 'ME' => 'Montenegro', 'MA' => 'Morocco', 'MZ' => 'Mozambique', 'MM' => 'Myanmar',
    'NA' => 'Namibia', 'NR' => 'Nauru', 'NP' => 'Nepal', 'NL' => 'Netherlands', 'NZ' => 'New Zealand',
    'NI' => 'Nicaragua', 'NE' => 'Niger', 'NG' => 'Nigeria', 'MK' => 'North Macedonia', 'NO' => 'Norway',
    'OM' => 'Oman', 'PK' => 'Pakistan', 'PW' => 'Palau', 'PS' => 'Palestine', 'PA' => 'Panama', 'PG' => 'Papua New Guinea',
    'PY' => 'Paraguay', 'PE' => 'Peru', 'PH' => 'Philippines', 'PL' => 'Poland', 'PT' => 'Portugal',
    'QA' => 'Qatar', 'RO' => 'Romania', 'RU' => 'Russia', 'RW' => 'Rwanda', 'KN' => 'Saint Kitts and Nevis',
    'LC' => 'Saint Lucia', 'VC' => 'Saint Vincent and the Grenadines', 'WS' => 'Samoa', 'SM' => 'San Marino',
    'ST' => 'Sao Tome and Principe', 'SA' => 'Saudi Arabia', 'SN' => 'Senegal', 'RS' => 'Serbia', 'SC' => 'Seychelles',
    'SL' => 'Sierra Leone', 'SG' => 'Singapore', 'SK' => 'Slovakia', 'SI' => 'Slovenia', 'SB' => 'Solomon Islands',
    'SO' => 'Somalia', 'ZA' => 'South Africa', 'SS' => 'South Sudan', 'ES' => 'Spain', 'LK' => 'Sri Lanka',
    'SD' => 'Sudan', 'SR' => 'Suriname', 'SE' => 'Sweden', 'CH' => 'Switzerland', 'SY' => 'Syria',
    'TJ' => 'Tajikistan', 'TZ' => 'Tanzania', 'TH' => 'Thailand', 'TL' => 'Timor-Leste', 'TG' => 'Togo',
    'TO' => 'Tonga', 'TT' => 'Trinidad and Tobago', 'TN' => 'Tunisia', 'TR' => 'Turkiye', 'TM' => 'Turkmenistan',
    'TV' => 'Tuvalu', 'UG' => 'Uganda', 'UA' => 'Ukraine', 'AE' => 'United Arab Emirates', 'GB' => 'United Kingdom',
    'US' => 'United States', 'UY' => 'Uruguay', 'UZ' => 'Uzbekistan', 'VU' => 'Vanuatu', 'VA' => 'Vatican City',
    'VE' => 'Venezuela', 'VN' => 'Vietnam', 'YE' => 'Yemen', 'ZM' => 'Zambia', 'ZW' => 'Zimbabwe',
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
