
require 'graphql'

QueryType = GraphQL::ObjectType.define do
  name 'Query'
  field :hello do
    type types.String
    argument :first, types.Int

    resolve -> (obj, args, context) do
      puts context.to_s
      puts args.to_h.to_s
      'Hello World'
    end
  end

  field :employees do
    type types[EmployeeType]
    argument :first, types.Int
    argument :id, types.Int

    resolve -> (query, args, context) do
      employees = Employee.where(merchant_token: context[:current_merchant].token)
      employees = employees.where(id: args[:id]) if args[:id].present?
      employees = employees.first(arg[:first]) if args[:first].present?

      employees
    end
  end

  field :units do
    type types[UnitType]
    argument :first, types.Int
    argument :id, types.Int

    resolve -> (query, args, context) do
      units = Unit.where(merchant_token: context[:current_merchant].token)
      units = units.where(id: args[:id]) if args[:id].present?
      units = units.first(args[:first]) if args[:first].present?

      units
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

CountryCodeEnum = GraphQL::EnumType.define do
  name 'CountryCode'
  description 'ISO 3166-1 Country Code'
  value 'USA'
  value 'GBR'
end

AddressType = GraphQL::ObjectType.define do
  name 'Address'
  field :line1, types.String
  field :line2, types.String
  field :country, CountryCodeEnum
end

UnitType = GraphQL::ObjectType.define do
  name 'Unit'
  field :unit_name, types.String
  field :address, AddressType
end

Schema = GraphQL::Schema.define do
  query QueryType
end
