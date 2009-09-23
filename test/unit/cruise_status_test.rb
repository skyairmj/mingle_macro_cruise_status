require File.join(File.dirname(__FILE__), 'unit_test_helper')

class CruiseStatusTest < Test::Unit::TestCase
  
  def test_cruise_authenticated
    cruise_status = CruiseStatus.new({"authenticate"=>"true"}, nil, nil)
    assert cruise_status.cruise_authenticated?
  end
  
  def test_url_for_cruise_without_authentication
    cruise_status = CruiseStatus.new({"cruise_url"=>"http://localhost:8153/cruise/", "pipeline_name"=>"sample","authenticate"=>"false"}, nil, nil)
    assert_equal('http://localhost:8153/cruise/pipelineStatus.json?pipelineName=sample', cruise_status.url)
  end
  
  def test_url_for_cruise_with_authentication
    cruise_status = CruiseStatus.new({"cruise_url"=>"http://10.9.4.113:8153/cruise/", "pipeline_name"=>"sample", "authenticate"=>"true", "username"=>"admin", "password"=>"admin"}, nil, nil)
    assert_equal('http://admin:admin@10.9.4.113:8153/cruise/pipelineStatus.json?pipelineName=sample', cruise_status.url)
    p cruise_status.execute
  end
  
  def test_interval_should_be_default_value_if_not_given
    cruise_status = CruiseStatus.new({},nil, nil)
    assert_equal CruiseStatus.default_interval, cruise_status.interval
  end
  
  def test_interval_by_given_value
    interval = 30
    cruise_status = CruiseStatus.new({"interval"=>interval}, nil, nil)
    assert_equal interval, cruise_status.interval
  end

end
