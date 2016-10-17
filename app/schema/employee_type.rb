require 'graphql'
require_relative './list_type'

EmployeeType = GraphQL::ObjectType.define do
  name 'Employee'
  field :token, types.String
  field :first_name, types.String
  field :last_name, types.String
  field :authorized_units do
    type types[types.String]
    resolve -> (employee, args, ctx) do
      puts ctx
      employee.authorized_subunits.map(&:token)
    end
  end
end

EmployeeListType = ListType.for_type(EmployeeType)
  .with_cursor_creator(Proc.new { |employee, args, context|
  "#{employee.created_at}:#{employee.token}"
}).with_cursor_parser(Proc.new { |cursor, args, context|
  created_at, token = cursor.split(':')
  ['created_at > ? AND token > ?', created_at, token]
}).build()

EmployeeEdgeType = EmployeeListType::Edge
