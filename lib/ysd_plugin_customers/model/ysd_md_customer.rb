require 'data_mapper' unless defined?DataMapper::Resource

module Yito
  module Model
    module Customers
      class Customer
        include DataMapper::Resource

        storage_names[:default] = 'customerds_customers'

        property :id, Serial
        property :customer_type, Enum[:individual, :legal_entity, :other], default: :individual
        property :company_name, String, length: 100
        property :name, String, length: 40
        property :surname, String, length: 40
        property :document_id, String, length: 50
        property :email, String, length: 40
        property :phone_number, String, length: 15
        property :mobile_phone, String, length: 15
        property :language, String, length: 3
        property :internal_notes, Text
        property :external_code, String, length: 100

        belongs_to :address, 'LocationDataSystem::Address', required: false # Address 
        belongs_to :invoice_address, 'LocationDataSystem::Address', required: false # Invoice address

        include BookingCustomer

        #
        # Exporting to json
        #
        def as_json(options={})

           if options.has_key?(:only)
             super(options)
           else
             relationships = options[:relationships] || {}
             relationships.store(:address, {})
             relationships.store(:invoice_address, {})
             super(options.merge({:relationships => relationships}))
           end

        end

      end
    end
  end
end