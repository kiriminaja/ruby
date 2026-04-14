.PHONY: install test build clean release

install:
	bundle install

test:
	bundle exec rake test

build: clean
	gem build kiriminaja.gemspec

clean:
	rm -f kiriminaja-*.gem

release: test build
	gem push kiriminaja-*.gem
