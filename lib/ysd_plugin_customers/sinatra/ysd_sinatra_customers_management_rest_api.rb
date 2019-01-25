#
# Middleware functionality
#
module Sinatra
 module YSD 
   module CustomersManagementRestApi
    
     def self.registered(app)
      
        #                    
        # Query customers
        #
        # == Query parameters
        #
        # page:: The page number (for pagination)
        # limit:: The page size (for pagination)
        # model:: 'select' to query for a select (simplified fields) 
        #
        # == Search parameters (body as json)
        #
        # search:: The search keyword
        # 
        ["/api/customers","/api/customers/page/:page"].each do |path|
          
          app.post path, :allowed_usergroups => ['booking_manager', 'booking_operator', 'staff'] do

            select_fields = [:id, :customer_type, :full_name, :document_id, :company_name, :company_document_id, :email, :phone_number, :mobile_phone]

            # Pagination, order and fields
            page = [params[:page].to_i, 1].max
            page_size = 20
            offset_order_query = {:offset => (page - 1)  * page_size, :limit => page_size, :order => [:full_name.asc]}
            offset_order_query.merge!(fields: select_fields) if params[:mode] == 'select'
            # Search  
            if request.media_type == "application/json"
              request.body.rewind
              search_request = JSON.parse(URI.unescape(request.body.read))            
              if search_request.has_key?('search') and (search_request['search'].to_s.strip.length > 0)
                search_text = search_request['search'].to_s.strip
                conditions = Conditions::JoinComparison.new('$or',
                                [Conditions::Comparison.new(:full_name, '$like', "%#{search_text}%"),
                                 Conditions::Comparison.new(:document_id, '$like', "%#{search_text}%"),
                                 Conditions::Comparison.new(:company_name, '$like', "%#{search_text}%"),
                                 Conditions::Comparison.new(:company_document_id, '$like', "%#{search_text}%"),                                 
                                 Conditions::Comparison.new(:email, '$like', "%#{search_text}%"),
                                 Conditions::Comparison.new(:phone_number, '$like', "%#{search_text}%"),
                                 Conditions::Comparison.new(:mobile_phone, '$like', "%#{search_text}%"),
                                ])  
                total = conditions.build_datamapper(::Yito::Model::Customers::Customer).all.count
                data = conditions.build_datamapper(::Yito::Model::Customers::Customer).all(offset_order_query)
              else
                data,total  = ::Yito::Model::Customers::Customer.all_and_count(offset_order_query)
              end  
            else
              data,total  = ::Yito::Model::Customers::Customer.all_and_count(offset_order_query)
            end

            content_type :json

            if params[:mode] == 'select'
              data_json = data.to_json(only: select_fields)
              summary_json= {total: total}.to_json
              "{\"data\": #{data_json}, \"summary\": #{summary_json}}"
            else  
              {:data => data, :summary => {:total => total}}.to_json
            end

          end
        
        end
        
        #
        # Search customer for autocomplete
        #
        # == Query parameters::
        #
        # term:: The search term (full_name, document_id, company_name, company_document_id, email, phone_number)
        #
        #
        app.get "/api/customers-search", :allowed_usergroups => ['booking_manager', 'booking_operator', 'staff'] do

          search_text = params[:term]

          conditions =  Conditions::JoinComparison.new('$or', [
                                                            Conditions::Comparison.new(:full_name, '$like', "%#{search_text}%"),
                                                            Conditions::Comparison.new(:document_id, '$like', "%#{search_text}%"),
                                                            Conditions::Comparison.new(:company_name, '$like', "%#{search_text}%"),
                                                            Conditions::Comparison.new(:company_document_id, '$like', "%#{search_text}%"),
                                                            Conditions::Comparison.new(:email, '$like', "%#{search_text}%"),
                                                            Conditions::Comparison.new(:phone_number, '$like', "%#{search_text}%")
                                                                 ])

          data = conditions.build_datamapper(::Yito::Model::Customers::Customer).all.map do |item|
            {value: item.id,
             label: item.full_name,
             type: item.customer_type,
             document_id: item.customer_type == :individual ? item.document_id : item.company_document_id,
             fullname: item.customer_type == :individual ? item.full_name : item.company_name }
          end

          status 200
          content_type :json
          data.to_json

        end

        #
        # Check customers by full_name, phone_number_1, phone_number_2, email, document_id
        #
        app.get '/api/customer-check', allowed_usergroups: ['booking_manager', 'booking_operator', 'staff'] do


          if params[:full_name] or params[:phone_number] or params[:phone_number_2] or params[:email] or params[:document_id]
            conditions_list = []
            conditions_list << Conditions::Comparison.new(:full_name, '$eq', params[:full_name]) if params[:full_name]
            conditions_list << Conditions::Comparison.new(:document_id, '$eq', params[:document_id]) if params[:document_id]
            conditions_list << Conditions::Comparison.new(:company_document_id, '$eq', params[:document_id]) if params[:document_id]
            conditions_list << Conditions::Comparison.new(:email, '$eq', params[:email]) if params[:email]
            conditions_list << Conditions::Comparison.new(:phone_number, '$eq', params[:phone_number_1]) if params[:phone_number_1]
            conditions_list << Conditions::Comparison.new(:phone_number, '$eq', params[:phone_number_2]) if params[:phone_number_2]
            conditions_list << Conditions::Comparison.new(:mobile_phone, '$eq', params[:phone_number_1]) if params[:phone_number_1]
            conditions_list << Conditions::Comparison.new(:mobile_phone, '$eq', params[:phone_number_2]) if params[:phone_number_2]
            conditions =  Conditions::JoinComparison.new('$or', conditions_list)
            fields = [:id, :full_name, :document_id, :company_name, :company_document_id, :email, :phone_number, :mobile_phone]
            data = conditions.build_datamapper(::Yito::Model::Customers::Customer).all(fields: fields).map do |item|
                      data = {id: item.id, full_name: item.full_name, document_id: item.document_id,
                              company_name: item.company_name, company_document_id: item.company_document_id,
                              email: item.email, phone_number: item.phone_number, mobile_phone: item.mobile_phone}
                      data
                   end
            status 200
            content_type :json
            data.to_json       
          else
            status 500
          end

        end

        #
        # Get a customer
        #
        app.get "/api/customer/:id", :allowed_usergroups => ['booking_manager', 'booking_operator', 'staff'] do
        
          data = ::Yito::Model::Customers::Customer.get(params[:id].to_i)
          
          status 200
          content_type :json
          data.to_json
        
        end
        
        #
        # Create a customer
        #
        app.post "/api/customer", :allowed_usergroups => ['booking_manager', 'booking_operator','staff'] do
        
          data_request = body_as_json(::Yito::Model::Customers::Customer)
          data = ::Yito::Model::Customers::Customer.create(data_request)
         
          status 200
          content_type :json
          data.to_json          
        
        end
        
        #
        # Updates a customer
        #
        app.put "/api/customer", :allowed_usergroups => ['booking_manager', 'booking_operator','staff'] do
          
          data_request = body_as_json(::Yito::Model::Customers::Customer)
          data_request.each do |k,v|
              if [:date_of_birth,
                  :driving_license_date,
                  :driving_license_expiration_date,
                  :document_id_date,
                  :document_id_expiration_date,
                  :additional_driver_1_date_of_birth,
                  :additional_driver_1_driving_license_date,
                  :additional_driver_1_driving_license_expiration_date,
                  :additional_driver_1_document_id_date,
                  :additional_driver_1_document_id_expiration_date,
                  :additional_driver_2_date_of_birth,
                  :additional_driver_2_driving_license_date,
                  :additional_driver_2_driving_license_expiration_date,
                  :additional_driver_2_document_id_date,
                  :additional_driver_2_document_id_expiration_date,
                  :additional_driver_3_date_of_birth,
                  :additional_driver_3_driving_license_date,
                  :additional_driver_3_driving_license_expiration_date,
                  :additional_driver_3_document_id_date,
                  :additional_driver_3_document_id_expiration_date,
                  :external_invoice_date].include?(k)
                data_request[k] = nil if v.empty?
              end
            end                              
          if data = ::Yito::Model::Customers::Customer.get(data_request.delete(:id))                      
            data.attributes=data_request  
            p "data_request:#{data_request.inspect}"
            p "data:#{data.valid?}--#{data.errors.full_messages.inspect}"
            data.save
          end
      
          content_type :json
          data.to_json        
        
        end
        
        #
        # Copy the customer address to the customer address
        #
        app.post "/api/customers/:id/copy-address-to-invoice-address", :allowed_usergroups => ['booking_manager', 'booking_operator','staff'] do
                                        
          if data = ::Yito::Model::Customers::Customer.get(params[:id])
            data.copy_address_to_invoice_address
          end
      
          content_type :json
          data.to_json        
        
        end

        #
        # Deletes a customer
        #
        app.delete "/api/customer", :allowed_usergroups => ['booking_manager', 'booking_operator','staff'] do
        
          data_request = body_as_json(::Yito::Model::Customers::Customer)
          
          key = data_request.delete(:id).to_i
          
          if data = ::Yito::Model::Customers::Customer.get(key)
            data.destroy
          end
          
          content_type :json
          true.to_json
        
        end

     end
    end #CustomersManagement 
 end #YSD
end #Sinatra
