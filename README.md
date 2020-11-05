# Bin collection schedules automation

[![Update Status](https://github.com/xinye1/bin_calendar/workflows/scheduled-run/badge.svg)](https://github.com/xinye1/bin_calendar/actions?query=workflow%3Ascheduled-run)


## Intro

This naively simple programme gets the schedules of the bin collection in my local area and updates a Google calendar. As I did not get permission to share the method to query the API outside of the designed route (on the council website) I will not expose any details, but the code does provide a framework of the process.

The main purpose of this repo is really for using Github Actions to update my calendar, and practice CI.

## Setup

### Main parameters

The UPRN and of course the API URL are needed for the council API query. The icons of bins are also referenced using an asset URL.

A little effort is made to avoid being banned by the API by using a random **User Agent string**. This is downloaded from [here](https://raw.githubusercontent.com/selwin/python-user-agents/master/user_agents/devices.json)

### GCP and Google Sheets

1. Create a GCP project
2. Enable Google Sheets API (found in the Market Place, search for "google sheets api")
3. Create a service account (SA) and download the key file
4. Create a new Google Sheets
5. Grand access for the SA email to the target Google Sheets
    * Run interactively on any systems it can be stored in e.g. `~/.gc_sa/`
    * For CI in Github store the JSON string as a GH secret (`GC_SA`)
6. Also need to store the Google Sheets ID as a GH secret (`GS_KEY_BIN`)

### Github Actions

#### Secrets

The following parameters are set for the CI

* `UPRN`
* `API_URL`
* `ASSET_URL`
* `GC_SA`
* `GS_KEY`

#### Crontab

Make gs_append.R executable

```bash
# if running the script using cron
chmod +x gs_update.R
# alternatively in Github Actions run R command using Rscript{0}
```

Add let crontab run at 12am every day

```bash
# if running the script using cron
0 0 * * * (./gs_update.R)
# alternatively in Github Actions run R command using Rscript{0}
```

## Apps Script

[Google Apps Script](https://developers.google.com/apps-script) is used for updating the actual calendar from Google Sheets.
