# Flarrent

Torrent client frontend for Transmission.  
This app will not run Transmission for you. It can only connect to a Transmission server that's already running.

## Cli Args
`--torrent <arg>` - Add a torrent. `<arg>` can be a magnet link, file path, or the base64 of a torrent file.

`--config <arg>` - Change the location of the config file.

## Config

Located by default in `~/.config/flarrent/config.json`. If the file/directories don't exist, launching the app will
create them.

Default config:
```json
{
  "color": "ff69bcff",
  "backgroundColor": "99000000",
  "connection": "transmission:http://localhost:9091/transmission/rpc",
  "smoothScroll": false
}
```


## Setting Transmission Server Options Through the Client

At the moment, this client does not include the functionality to configure Transmission server options,
such as altering the 'peer port,' changing the download directory, or setting global limits (though you can still toggle alternative limits).

The reason for this omission is that I, the creator of this client, have configured my own Transmission server using Nix.
This setup allows me to define various settings through Nix code.
Therefore, incorporating the ability to configure server options through the client would not provide any advantages for me.

However, I am open to pull requests (PRs). If you wish to see this feature added, please consider contributing it if you can! 😄
