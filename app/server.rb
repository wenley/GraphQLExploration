
require 'sinatra'
require_relative 'schema'

post '/' do
  Schema.execute(request.body.read.to_s).to_s
end
