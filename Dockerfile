# Use the official Ruby image
ARG RUBY_VERSION=3.3.5
FROM ruby:$RUBY_VERSION-slim AS base

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential git

# Set the working directory
WORKDIR /app

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the project files
COPY . .

# Command to run the test script
CMD ["bundle exec ruby", "test_micro_batching_library.rb"]
