<p align="center">
<img src="./.github/logo.svg" width="500px" alt="NeoFS">
</p>
<p align="center">
  UN/LOCODE database for <a href="https://frostfs.info">ForstFS</a>
</p>

---
![GitHub release](https://img.shields.io/github/release/TrueCloudLab/frostfs-locode-db.svg)
![GitHub license](https://img.shields.io/github/license/TrueCloudLab/frostfs-locode-db.svg?style=popout)

# Overview

This repository contains instructions to generate UN/LOCODE database for FrostFS
and raw representation of it. FrostFS uses UN/LOCODE in storage node attributes
and storage policies. Inner ring nodes converts UN/LOCODE into human-readable
set of attributes such as continent, country name, etc.

# Build

## Prerequisites

- Latest [frost] tool(https://github.com/TrueCloudLab/frostfs-node)
- [UN/LOCODE](https://unece.org/trade/cefact/UNLOCODE-Download)
  database in CSV format
- [OpenFlight Airports](https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat)
  database
- [OpenFlight Countries](https://raw.githubusercontent.com/jpatokal/openflights/master/data/countries.dat)
  database

## Quick start

Just run `make` to generate `locode_db` file for use with FrostFS InnerRing nodes.

``` shell
$ make
...
--out locode_db
```

## Building

First unzip file with GeoJSON continents from this repository.
```
$ gunzip continents.geojson
```

Then run frost command to generate boltDB file.
```
$ frost util locode generate --help
generate UN/LOCODE database for FrostFS

Usage:
  frost util locode generate [flags]

Flags:
      --airports string     Path to OpenFlights airport database (csv)
      --continents string   Path to continent polygons (GeoJSON)
      --countries string    Path to OpenFlights country database (csv)
  -h, --help                help for generate
      --in strings          List of paths to UN/LOCODE tables (csv)
      --out string          Target path for generated database
      --subdiv string       Path to UN/LOCODE subdivision database (csv)

$ ./frost util locode generate \
  --airports airports.dat \
  --continents continents.geojson \
  --countries countries.dat \
  --in 2022-1\ UNLOCODE\ CodeListPart1.csv,2022-1\ UNLOCODE\ CodeListPart2.csv,2022-1\ UNLOCODE\CodeListPart3.csv \
  --subdiv 2020-2\ SubdivisionCodes.csv \
  --out locode_db
```

**Database generation might take some time!**

You can test generated database with `frost`.
```
$ frost util locode info --db locode_db --locode 'RU LED'
Country: Russia
Location: Saint Petersburg (ex Leningrad)
Continent: Europe
Subdivision: [SPE] Sankt-Peterburg
Coordinates: 59.88, 30.25
```

# Building Debian package

The most simple way is to run a make target

```shell
$ make debpackage
```

When packages are built, you can clean up the leftover with

```shell
$ dh clean
```
or
```shell
$ make debclean
```


## License

This project is licensed under the CC Attribution-ShareAlike 4.0 International -
see the [LICENSE](LICENSE) file for details
