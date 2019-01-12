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
        ["/api/customers","/api/customers/page/:page"].each do |path|
          
          app.post path, :allowed_usergroups => ['booking_manager','staff'] do

            page = [params[:page].to_i, 1].max
            page_size = 20
            offset_order_query = {:offset => (page - 1)  * page_size, :limit => page_size, :order => [:name.asc]}

            if request.media_type == "application/json"
              request.body.rewind
              search_request = JSON.parse(URI.unescape(request.body.read))
              
              if search_request.has_key?('search') and (search_request['search'].to_s.strip.length > 0)
                search_text = search_request['search'].to_s.strip
                conditions = Conditions::JoinComparison.new('$or',
                                [Conditions::Comparison.new(:full_name, '$like', "%#{search_text}%"),
                                 Conditions::Comparison.new(:document_id, '$like', "%#{search_text}%"),
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
            {:data => data, :summary => {:total => total}}.to_json
          
          end
        
        end
        
        #
        # Get all customer
        #
        app.get "/api/customers", :allowed_usergroups => ['booking_manager','staff'] do

          data = ::Yito::Model::Customers::Customer.all()

          status 200
          content_type :json
          data.to_json

        end

        #
        # Search customer
        #
        app.get "/api/customers-search", :allowed_usergroups => ['booking_manager', 'staff'] do

          search_text = params[:term]

          conditions =  Conditions::JoinComparison.new('$or', [
                                                            Conditions::Comparison.new(:surname, '$like', "%#{search_text}%"),
                                                            Conditions::Comparison.new(:email, '$like', "%#{search_text}%"),
                                                            Conditions::Comparison.new(:phone_number, '$like', "%#{search_text}%")
                                                                 ])

          data = conditions.build_datamapper(::Yito::Model::Customers::Customer).all.map do |item|
            {value: item.id,
             label: "#{item.name} #{item.surname}"}
          end

          status 200
          content_type :json
          data.to_json

        end

        #
        # Get a customer
        #
        app.get "/api/customer/:id", :allowed_usergroups => ['booking_manager','staff'] do
        
          data = ::Yito::Model::Customers::Customer.get(params[:id].to_i)
          
          status 200
          content_type :json
          data.to_json
        
        end
        
        #
        # Create a customer
        #
        app.post "/api/customer", :allowed_usergroups => ['booking_manager','staff'] do
        
          data_request = body_as_json(::Yito::Model::Customers::Customer)
          data = ::Yito::Model::Customers::Customer.create(data_request)
         
          status 200
          content_type :json
          data.to_json          
        
        end
        
        #
        # Updates a customer
        #
        app.put "/api/customer", :allowed_usergroups => ['booking_manager','staff'] do
          
          data_request = body_as_json(::Yito::Model::Customers::Customer)
                              
          if data = ::Yito::Model::Customers::Customer.get(data_request.delete(:id))
            data.attributes=data_request  
            data.save
          end
      
          content_type :json
          data.to_json        
        
        end
        
        #
        # Copy the customer address to the customer address
        #
        app.post "/api/customers/:id/copy-address-to-invoice-address", :allowed_usergroups => ['booking_manager','staff'] do
                                        
          if data = ::Yito::Model::Customers::Customer.get(params[:id])
            data.copy_address_to_invoice_address
          end
      
          content_type :json
          data.to_json        
        
        end

        #
        # Deletes a customer
        #
        app.delete "/api/customer", :allowed_usergroups => ['booking_manager','staff'] do
        
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
