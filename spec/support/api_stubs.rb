require 'fakeweb'
require 'json'

VENDOR_JSON = {}

VENDOR_JSON[:DKBenchmark] = { :name => "DKBenchmark",
                              :description => "Easy benchmarking in Objective-C using blocks",
                              :release => "0.2",
                              :versions => [
                                [ "0.3.alpha1",
                                  { :dependencies => [ ["AFNetworking","~> 0.9.2"], ["ASIHTTPRequest", nil] , ["JSONKit","0.5"] ] } ],
                                [ "0.2",
                                  { :dependencies => [ ["JSONKit","0.5"] ] } ],
                                [ "0.1",
                                  { :dependencies => [ ] } ]
                              ]
                            }

VENDOR_JSON[:DKBenchmarkCrazyName] = VENDOR_JSON[:DKBenchmark].merge(:name => "DKBenchmark!! With Some Crazy #Number Name!")

FakeWeb.register_uri :get, "http://keithpitt:password@vendorforge.org/users/keithpitt/api_key.json",
                     :body => { :api_key => "secret" }.to_json

FakeWeb.register_uri :get, "http://keithpitt:wrong@vendorforge.org/users/keithpitt/api_key.json",
                     :status => 401

FakeWeb.register_uri :get, "http://keithpitt:error@vendorforge.org/users/keithpitt/api_key.json",
                     :status => 500

FakeWeb.register_uri :get, "http://vendorforge.org/vendors/DKBenchmark.json",
                     :body => VENDOR_JSON[:DKBenchmark].to_json

FakeWeb.register_uri :get, "http://vendorforge.org/vendors/DKBenchmark-With-Some-Crazy-Number-Name-.json",
                     :body => VENDOR_JSON[:DKBenchmarkCrazyName].to_json

FakeWeb.register_uri :get, "http://vendorforge.org/vendors/WithAnError.json",
                     :status => 500

FakeWeb.register_uri :get, "http://vendorforge.org/vendors/DoesNotExist.json",
                     :status => 404

FakeWeb.allow_net_connect = false
