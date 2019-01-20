require 'data_mapper' unless defined?DataMapper::Resource

module Yito
  module Model
    module Customers
      class Customer
        include DataMapper::Resource

        storage_names[:default] = 'customerds_customers'

        property :id, Serial
        property :customer_type, Enum[:individual, :legal_entity], default: :individual
        property :company_name, String, length: 100
        property :company_document_id, String, length: 50
        property :name, String, length: 40
        property :surname, String, length: 40
        property :full_name, String, length: 80
        property :full_surname_name, String, length: 80
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
        extend Yito::Model::Finder

        before :save do
            if self.name and self.surname and !self.name.empty? and !self.surname.empty? 
              self.full_name = "#{self.name} #{self.surname}"
              self.full_surname_name = "#{self.surname}, #{self.name}" 
            end
        end    

        #
        # Copy the address to the invoce address
        #
        def copy_address_to_invoice_address

          if self.address
            self.invoice_address = LocationDataSystem::Address.new if invoice_address.nil?
            self.invoice_address.street = address.street
            self.invoice_address.number = address.number
            self.invoice_address.complement = address.complement
            self.invoice_address.city = address.city
            self.invoice_address.state = address.state
            self.invoice_address.zip = address.zip
            self.invoice_address.country = address.country
            self.invoice_address.save
            self.save
          end  

        end  

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