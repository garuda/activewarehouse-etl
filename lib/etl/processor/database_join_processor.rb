module ETL
  module Processor
    class DatabaseJoinProcessor < ETL::Processor::RowProcessor
      attr_reader :target
      attr_reader :query
      attr_reader :fields

      # Initialize the procesor.
      #
      # Arguments:
      # * <tt>control</tt>: The ETL::Control::Control instance
      # * <tt>configuration</tt>: The configuration Hash
      # * <tt>definition</tt>: The source definition
      #
      # Required configuration options:
      # * <tt>:target</tt>: The target connection
      # * <tt>:query</tt>: The join query
      # * <tt>:fields</tt>: The fields to add to the row
      def initialize(control, configuration)
        super
        @target = configuration[:target]
        @query = configuration[:query]
        @fields = configuration[:fields]
      end
      
      # Get a String identifier for the source
      def to_s
        "#{host}/#{database}"
      end
      
      def process(row)
        return nil if row.nil?

        q = @query
        begin
          q = eval('"' + @query + '"')
        rescue
        end

        ETL::Engine.logger.debug("Executing select: #{q}")
        res = connection.execute(q)

        res.each_hash do |r|
          @fields.each do |field|
            row[field.to_sym] = r[field]
          end
        end

        return row
      end

      private
      # Get the database connection to use
      def connection
        ETL::Engine.connection(target)
      end
      
      # Get the host, defaults to 'localhost'
      def host
        ETL::Base.configurations[target.to_s]['host'] || 'localhost'
      end
      
      def database
        ETL::Base.configurations[target.to_s]['database']
      end
    end
  end
end
