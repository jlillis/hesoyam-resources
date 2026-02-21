# HESOYAM: Accounts 1.0.0

This resource implements a player account system, replacing the internal one used by MTA. It features:
* Account lockout and log level settings
* Strong encryption with MTA's `passswordHash` and `passwordVerify` functions
* Token-based authentication (for autologin/"Remember me" functionality)
* A server- and client-side API for integration with other resources

Accounts are stored in the server's SQL database. **The HESOYAM: Database resource is required.**

### Username & password requirements
Usernames must:
* Be between 1 and 22 characters long
* Contain only letters and numbers
* Be unique - usernames are stored and compared in lower-case

Passwords must:
* Be at least 8 characters long

### Token-based authentication
A token is a unique string bound to an account ID, username, client serial, and IP address that can be used to authenticate to an account one time. Clients can request a token from the server after logging in and use it to log in automatically (without a password). Tokens are single-use: a new token must be requested after each use.

## Setup

1. Initialize the database by executing the *accounts.sql* script on your SQL server.
2. Copy *server/config.lua.example* to *server/config.lua* and configure the settings for your environment.
3. Add `<include resource="accounts"/>` to the *meta.xml* of other resources that require player account functionality. This resource will start automatically when the first resource to require it is started.

## API
### Server Functions
* `isPlayerLoggedIn(player)`: returns true if `player` is logged in, false otherwise.
* `getPlayerAccountID(player)`: returns `player`'s account ID if they are logged in, false otherwise.

### Server Events
* `onPlayerLogin`: triggered when a player logs in. The `source` of this event is the player that logged in.
* `onPlayerLogout`: triggered when a player logs out. The `source` of this event is the player that logged out.

### Client Functions
* `sendLoginRequest(loginMethod, usernameOrToken[, password])`: sends a login request to the server. The `onClientLoginResponse` event will be triggered when a response is received. This will fail if a request is already pending. Returns true if the request was sent, false otherwise.
    * `type`: the type of login being requested: either "password" for a username/password-based request or "token" for a token-based request
    * `usernameOrToken`: for password-based attempts, this is an account username. For token-based requests, this is a token.
    * `password` (optional): the account password (for password-based attempts)
* `sendLogoutRequest()`: sends a logout request to the server. This will fail if the client is not logged in. Returns true if the request was sent, false otherwise. The `onClientPlayerLogout` event will be triggered when the client is logged out.
* `sendRegistrationRequest(username, password)`: sends a registration request to the server for an account with the given username and password. The `onClientRegistrationResponse` event will be triggered when a response is received. This will fail if a request is already pending. Returns true if the request was sent, false otherwise.
    * `username`: the requested username
    * `password`: the requested password
* `sendTokenRequest()`: sends a token request to the server. The `onClientTokenResponse` event will be triggered when a reponse is recieved. This will fail if the player is not logged in. Returns true if the request was sent, false otherwise

### Client Events
* `onClientLoginResponse(responseCode)`: triggered when the server has responded to an login request. The `source` of this event is always `localPlayer`. `responseCode` will be:
    * 1 if the client was logged in successfully
    * 2 if a generic error occurred
    * 3 if the client is locked out
    * 4 if the username or password were invalid (for password-based authentication)
    * 5 if the token was invalid (for token-based authentication)
* `onClientRegistrationResponse(responseCode)`: triggered when the server has responded to a registration request. The `source` of this event is always `localPlayer`. `responseCode` will be:
    * 1 if registration succeeded and the account was created
    * 2 if a generic error occurred
    * 3 if the requested username does not meet the requirements
    * 4 if the requested password did not meet complexity requirements
    * 5 if the requested username is already in use
* `onClientTokenResponse(token)`: triggered when the server has responded to a token request. The `source` of this event is always `localPlayer`. `token` will be the new token associated with the client, or false if the request failed.
* `onClientPlayerLogin`: triggered when a player logs in. The `source` of this event is the player that logged in.
* `onClientPlayerLogout`: triggered when a player logs out. The `source` of this event is the player that logged out.

## LICENSE
See LICENSE.txt for license information.
