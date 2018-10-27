# Docker Mautic

This is yet another docker image for [Mautic](https://github.com/mautic/mautic).
It takes inspiration from the [official
image](https://github.com/mautic/docker-mautic) and the one from
[@mingfang](https://github.com/mingfang/docker-mautic).

Use at your own risk

You can pull it directly from the Docker hub:
```
$ docker pull mayeu/mautic
```

The tags used follow this convention
`mayeu/mautic:<mautic-version>-<incremental-number>`. The incremental number is
bumped on every bugfix and feature.

Documentation of all the possible env variable is lacking but you can check
[this file](./config/local.php) for a list.
