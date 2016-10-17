
require 'graphql'
require_relative './employee_type'

EmployeeEdgeType = GraphQL::ObjectType.define do
  name 'EmployeeEdge'
  description 'Connection to an Employee'

  field :node, Employee, resolver: -> (employee_edge, args, context) { employee_edge }
  field :cursor do
    type !types.String
    resolver -> (employee, args, context) do
      # THIS IS SPECIFIC
      "#{employee.created_at}:#{employee.token}"
    end
  end
end

EmployeeListType = GraphQL::ObjectType.define do
  name 'EmployeeList'

  field :edges do
    type types[EmployeeEdge]

    argument :first, types.Int
    argument :id, types.String()
    argument :after, types.String()

    resolve -> (has_employee_object, args, context) do
      employees = has_employee_object.employees
      employees = employees.where(id: args[:id]) if args[:id].present?
      employees = employees.where(cursor_query(args[:after])) if args[:after].present?
    end
  end

  field :total_count do
    type !types.Int
    resolve -> (has_employees_object, args, context) do
      has_employees_object.employees.count
    end
  end
end

class EmployeeListType
  def cursor_query(cursor_value)
    # THIS IS SPECIFIC
    ['employees.created_at > ?', cursor_value]
  end
end
