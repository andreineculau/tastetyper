# Tastetyper

A wiki with taste i.e. minimalistic

For a *pastebin* flavour of Tastetyper, see https://github.com/andreineculau/tastebin

* server: NodeJS, CoffeeScript, ExpressJS, ...
* client: HTML5, CoffeeScript, Marked, HighlightJs, ...

![README](SEEME.png)


## Install and run

```sh
git clone git://github.com/andreineculau/tastetyper.git
cd tastetyper
npm install
# edit config.coffee as you see fit
npm start
```

Here's what you can configure out-of-the-box: [config.coffee](config.coffee).

In production, try

* [forever](https://github.com/foreverjs/forever)
* [upstarter](https://github.com/carlos8f/node-upstarter)
* ...

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/andreineculau/tastetyper)


## Tested browsers

* Chrome 44
* Opera 30
* Safari 8
* Firefox 39


## License

[Apache 2.0](LICENSE)
