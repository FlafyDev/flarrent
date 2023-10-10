# Flarrent
## WIP

Torrent client frontend for Transmission

## TODO before completion

- [x] Add config file. (main color, connection settings)
- [x] Don't hardcode the main color
- [x] Option to pick torrent file from the app.
- [x] Overall up / down rates.
- [x] Free space.
- [x] CLI argument: config location.
- [x] CLI argument: add magnet link / torrent file.
- [x] Smooth scroll
- [ ] Desktop file for magnets and torrent files

## Setting Transmission Server Options Through the Client

At the moment, this client does not include the functionality to configure Transmission server options,
such as altering the 'peer port,' changing the download directory, or setting global limits (though you can still enable alternative limits).

The reason for this omission is that I, the creator of this client, have configured my own Transmission server using Nix.
This setup allows me to define various settings within the Nix code.
Therefore, incorporating the ability to configure server options through the client would not provide any advantages for me.

However, I am open to pull requests (PRs). If you wish to see this feature added, please consider contributing it if you can! 😄
