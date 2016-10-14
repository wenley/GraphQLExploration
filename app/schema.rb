
require 'graphql'

CursorInputType = GraphQL::InputObjectType.define do
  name 'Cursor'
  input_field :created_at, !types.String
end

QueryType = GraphQL::ObjectType.define do
  name 'Query'
  field :hello do
    type types.String
    argument :first, types.Int
    argument :cursor, CursorInputType

    resolve -> (obj, args, context) do
      puts context.to_s
      puts args.to_h.to_s
      'Hello World'
    end
  end
end

EmployeeType = GraphQL::ObjectType.define do
  name 'Employee'
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

Schema = GraphQL::Schema.define do
  query QueryType
end
