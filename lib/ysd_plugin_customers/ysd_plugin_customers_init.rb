require 'ysd-plugins' unless defined?Plugins::Plugin

Plugins::SinatraAppPlugin.register :customers do

   name=        'customers'
   author=      'yurak sisa'
   description= 'Integrate customers'
   version=     '0.1'
   sinatra_extension Sinatra::YSD::Customers  
   sinatra_extension Sinatra::YSD::CustomersManagement
   sinatra_extension Sinatra::YSD::CustomersManagementRestApi                 
   hooker            Huasi::CustomersExtension
  
end