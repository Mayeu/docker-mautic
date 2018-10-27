<?php
use Mautic\CoreBundle\Helper\EncryptionHelper;

// This is vaguely inspired from the one from the official docker image
$stderr = fopen('php://stderr', 'w');
$stdout = fopen('php://stdout', 'w');

function return_or_default($to_return, $default_value = null)
{
    if(getenv($to_return)) {
        return getenv($to_return);
    }

    return $default_value;
}

$parameters = array(
    'api_enabled'       => getenv('MAUTIC_API_ENABLE') !== "true" ? true : false,
	'db_driver'         => 'pdo_mysql',
	'install_source'    => 'Docker',
    'db_host'           => return_or_default('MAUTIC_DB_HOST'),
    'db_port'           => return_or_default('MAUTIC_DB_PORT', '3306'),
    'db_name'           => return_or_default('MAUTIC_DB_NAME', 'mautic'),
    'db_user'           => return_or_default('MAUTIC_DB_USER', 'mautic'),
    'db_password'       => return_or_default('MAUTIC_DB_PASSWORD'),
    'db_table_prefix'   => return_or_default('MAUTIC_DB_TABLE_PREFIX'),
    'db_backup_tables'  => 0,
    'db_backup_prefix'  => 'bak_',
    'trusted_proxies'   => getenv('MAUTIC_TRUSTED_PROXIES') ? explode(',', getenv('MAUTIC_TRUSTED_PROXIES')) : null,
    #'mailer_from_name'  => return_or_default('MAUTIC_MAILER_FROM_NAME'),
    'mailer_from_email' => return_or_default('MAUTIC_MAILER_FROM_EMAIL'),
    'mailer_transport'  => return_or_default('MAUTIC_MAILER_TRANSPORT', 'smtp'),
    'mailer_host'       => return_or_default('MAUTIC_MAILER_SMTP_HOST'),
    'mailer_port'       => return_or_default('MAUTIC_MAILER_SMTP_PORT', '587'),
    'mailer_password'   => return_or_default('MAUTIC_MAILER_SMTP_PASSWORD'),
    'mailer_encryption' => return_or_default('MAUTIC_MAILER_SMTP_ENCRYPTION', 'tls'),
    'mailer_auth_mode'  => return_or_default('MAUTIC_MAILER_SMTP_AUTH_MODE', 'plain'),
    'mailer_spool_type' => 'file',
	'mailer_spool_path' => '%kernel.root_dir%/spool',
    'site_url'          => return_or_default('MAUTIC_SITE_URL')
);

$path     = getenv('MAUTIC_LOCAL_CONFIG') . '/local.php';
$rendered = "<?php\n\$parameters = ".var_export($parameters, true).";\n";

$status = file_put_contents($path, $rendered);

if ($status === false) {
	fwrite($stderr, "\nCould not write configuration file to $path, you can create this file with the following contents:\n\n$rendered\n");
}
