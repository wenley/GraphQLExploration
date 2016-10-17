
require 'graphql'

class ListType
  # Map from Node types to the constructed ListType
  CREATED_TYPES = {}

  def self.for_type(type)
    Builder.new(type)
  end

  class Builder
    def initialize(type)
      @type = type
    end

    # Takes an object and potential arguments + context
    # Returns a string
    def with_cursor_creator(proc)
      raise ArgumentError unless proc.arity == 3

      @output_proc = proc
      self
    end

    # Proc must take a String and parse into a SQL Where
    def with_cursor_parser(proc)
      raise ArgumentError unless proc.arity == 3

      @input_proc = proc
      self
    end

    def build
      edge_type = GraphQL::ObjectType.define do
        name "Edge<#{@type.class.name}>"
        description "Connection to a #{@type.class.name}"

        field :node do
          type @type
          resolve -> (edge, args, context) { edge }
        end

        field :cursor do
          type !types.String
          resolve @output_proc
        end
      end

      list_type_name = "ListType<#{@type.name}>"
      list_description = "A generic paginated collection of #{@type.name}"
      list_type = GraphQL::ObjectType.define do
        name list_type_name
        description list_description

        field :edges do
          type types[edge_type]

          argument :first, types.Int
          argument :id, types.String()
          argument :after, types.String()

          resolve -> (parent_object, args, context) do
            employees = parent_object.employees
            employees = employees.where(id: args[:id]) if args[:id].present?
            employees = employees.where(@input_proc.call(args[:after])) if args[:after].present?
          end
        end
      end

      list_type.singleton_class.const_set(:Edge, edge_type)
      ListType::CREATED_TYPES[@type] = list_type

      # Could do some const setting to make namespace nicer

      list_type
    end
  end
end
