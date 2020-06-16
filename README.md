# APPROOV TLS CERTIFICATES MONITOR

Bash script to monitor all APIs domains registered in an Approov account.

## INSTALL

Create an Approov folder:

```
mkdir ~/.approov && cd ~/.approov
```

Clone the repo:

```
git clone https://github.com/approov/approov-tls-certificates-monitor.git && cd approov-tls-certificates-monitor
```

## SETUP

The setup is done via an `.env` file:

```
cp .env.example .env
```

Read the comments on the `.env.example` file and adjust the values to fit your needs.


## RUN THE MONITOR FROM DOCKER

#### Build

```
./stack build
```

#### Dry Run

```
./stack run dry-run
```

#### Run Once

```
./stack run check
```

#### Run Forever

```
./stack up
```


## RUN THE MONITOR FROM THE HOST

To run the monitor from the host we assume that you already have installed the [Approov CLI](https://approov.io/docs/latest/approov-installation/#approov-tool) and it's located somewhere in your `$PATH`, like at `/home/USER_NAME/.local/bin`, thus if you have not installed it, we provide an helper bash script to do it so.

### Install the Approov CLI

##### command

```
./bin/install-approov-cli.sh
```

##### output:

```
...

Approov Tool 2.3.1
Copyright (c) 2016-2020 CriticalBlue Ltd.

...
```

### Run as a Systemd Service Unit

##### command:

```
./bin/run-monitor-via-systemd.sh
```

##### output:

```
...

Created symlink /etc/systemd/system/default.target.wants/approov-tls-certificates-monitor.service → /etc/systemd/system/approov-tls-certificates-monitor.service.

The systemd service is now running every 5 minutes.

Check the email alert@email.com to see the result for the first run.

...
```

#### Check systemd status

```
sudo systemctl status approov-tls-certificates-monitor.service
```

### Run as a Cron Job

##### command:

```
./bin/run-monitor-via-cronjob.sh
```

##### output:

```
...

Cron job is now running every 5 minutes.

Check the email alert@email.com to see the result for the first run.
```
