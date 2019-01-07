require 'data_mapper' unless defined?DataMapper::Resource

module Yito
  module Model
    module Customers
      module BookingCustomer
   
	    def self.included(model)
	     
	     if model.respond_to?(:property)
	     
	       model.property :document_id_date, DateTime
	       model.property :document_id_expiration_date, DateTime
	       model.property :origin_country, String, :length => 80
	       model.property :date_of_birth, DateTime

	       model.property :driving_license_number, String, :length => 50
	       model.property :driving_license_date, DateTime 
	       model.property :driving_license_country, String, :length => 50
	       model.property :driving_license_expiration_date, DateTime	       

	       # Additional drivers
	       model.property :additional_driver_1_name, String, :length => 40
	       model.property :additional_driver_1_surname, String, :length => 40
	       model.property :additional_driver_1_date_of_birth, DateTime
	       model.property :additional_driver_1_driving_license_number, String, :length => 50
	       model.property :additional_driver_1_driving_license_date, DateTime
	       model.property :additional_driver_1_driving_license_country, String, :length => 50
	       model.property :additional_driver_1_driving_license_expiration_date, DateTime
	       model.property :additional_driver_1_document_id, String, :length => 50
	       model.property :additional_driver_1_document_id_date, DateTime
	       model.property :additional_driver_1_document_id_expiration_date, DateTime
	       model.property :additional_driver_1_phone, String, :length => 15
	       model.property :additional_driver_1_email, String, :length => 40
	       model.property :additional_driver_1_origin_country, String, :length => 80

	       model.property :additional_driver_2_name, String, :length => 40
	       model.property :additional_driver_2_surname, String, :length => 40
	       model.property :additional_driver_2_date_of_birth, DateTime
	       model.property :additional_driver_2_driving_license_number, String, :length => 50
	       model.property :additional_driver_2_driving_license_date, DateTime
	       model.property :additional_driver_2_driving_license_country, String, :length => 50
	       model.property :additional_driver_2_driving_license_expiration_date, DateTime
	       model.property :additional_driver_2_document_id, String, :length => 50
	       model.property :additional_driver_2_document_id_date, DateTime
	       model.property :additional_driver_2_document_id_expiration_date, DateTime
	       model.property :additional_driver_2_phone, String, :length => 15
	       model.property :additional_driver_2_email, String, :length => 40
	       model.property :additional_driver_2_origin_country, String, :length => 80

	       model.property :additional_driver_3_name, String, :length => 40
	       model.property :additional_driver_3_surname, String, :length => 40
	       model.property :additional_driver_3_date_of_birth, DateTime
	       model.property :additional_driver_3_driving_license_number, String, :length => 50
	       model.property :additional_driver_3_driving_license_date, DateTime
	       model.property :additional_driver_3_driving_license_country, String, :length => 50
	       model.property :additional_driver_3_driving_license_expiration_date, DateTime
	       model.property :additional_driver_3_document_id, String, :length => 50
	       model.property :additional_driver_3_document_id_date, DateTime
	       model.property :additional_driver_3_document_id_expiration_date, DateTime
	       model.property :additional_driver_3_phone, String, :length => 15
	       model.property :additional_driver_3_email, String, :length => 40
	       model.property :additional_driver_3_origin_country, String, :length => 80

	     end

	    end 	

      end
    end
  end
end    		