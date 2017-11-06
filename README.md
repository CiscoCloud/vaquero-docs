# vaquero-docs

Documentation for the Vaquero project: [https://github.com/CiscoCloud/vaquero](https://github.com/CiscoCloud/vaquero)

Website: [https://ciscocloud.github.io/vaquero-docs](https://ciscocloud.github.io/vaquero-docs)


## How to modify the documentation

Updates to this repo automatically generate new documentation which will be published as static assets to using the GitHub Pages functionality.  The documentation will be published according to these rules:

* Changes to the `master` branch are published into the `current` version of the documentation.

  https://github.com/CiscoCloud/vaquero-docs/tree/master/docs/current

* When the documentation is tagged, a new version of the documents will be published using the version indicated in the tag. **Future Roadmap**

  See: https://github.com/CiscoCloud/vaquero-docs/tree/master/docs

* Individual branches will be published, as well.

  https://github.com/CiscoCloud/vaquero-docs/tree/master/docs/branches


## Local Development

Install Ruby

  [RVM](http://rvm.io) is a great tool for this. Follow the install instructions and then install the version in the [.ruby-version](.ruby-version) file.

    rvm install 2.4.2

Setup a gemset so your gems are isolated

    rvm create gemset vqdocs

Install bundler

    gem install bundler

Install gems (from the [Gemfile](Gemfile) file)

    bundle install

Start jekyll to see the site

    jekyll serve

View in your browser

    http://localhost:4000


Make changes and jekyll will rebuild the site automatically.

