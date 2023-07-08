# HESOYAM: Database 1.0.0

This resource provides a simple interface for other resources to retrieve a handle for the server's SQL database. Compatible with MySQL and SQLite databases.

## Setup

1. Copy *server/config.lua.example* to *server/config.lua* and configure the settings for your environment.
2. Add `<include resource="database"/>` to the *meta.xml* file of other resources that require database functionality. This resource will start and connect to the database automatically when the first resource to include it is started. Connection errors will be logged to the server console.

## API
### Server Functions
* `getDatabase()`: returns the SQL database handle, or `false` if the database isn't connected.

## LICENSE
See LICENSE.txt for license information.
