# Franca-JS

This is a library meant to make it easy to get and view data from different backends. Queries are encoded in a common JSON format that can be translated for use with different data backend sources, such as Mongo or Solr.


## Overview

Franca queries are intended to be a common query format for the basic queries common to most data backends, capturing things like ```and``` and ```or``` relationships, negation, and regex.

Franca queries also support a raw mode that allow the user to pass a native query to the backend, exposing the full features of the underlying data resource.
