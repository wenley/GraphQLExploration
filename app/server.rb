
require 'sinatra'
require_relative 'schema'

get '/' do
  Schema.execute(<<-SQL
    { hello(first: 1, cursor: { created_at: "aoeu" }) }
                 SQL
                ).to_s
end
