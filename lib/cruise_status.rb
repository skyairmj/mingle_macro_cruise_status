require 'activesupport'

class CruiseStatus
  @@DEFULT_INTERVAL = 180

  def initialize(parameters, project, current_user)
    @parameters = parameters
    @project = project
    @current_user = current_user
  end
  
  def execute
    <<-HTML
      <script src="/javascripts/jsonp.js" type="text/javascript"></script>
      <script type="text/javascript">
      function generateLightBox(pipeline, stage){
        return '<ul>'+
          '<li>Stage: '+ stage.stageName+
          '<li>Time: '+ stage.builds[0].build_completing_date +
          '<li>Last Checkin '+
          '<ul>'+
          '<li style="list-style: circle">'+ stage.materialRevisions[0].modifications[0].user +
          '<li style="list-style: circle">'+ stage.materialRevisions[0].modifications[0].comment +
          '</ul>'+
          '</ul>';
      }
      
      function getCruiseStatusReport(){
        return '<div class="action-bar-inner-wrapper" style="font-size:160%">'+
          '<div><div style="float:left"><h1>Stop the line!</h1></div><div style="float:right"><img src="/images/stop-the-line.png"/></div>'+
          '<div style="clear:both"></div>'+
          '</div>'+
          '<h2>The build is Failing...</h2>'+
          '<p id="cruise_status_report" style="margin:0px"></p>'+
        '</div>';
      }
      
      function isBuildFailed(stage){
        return stage.current_status == 'failed';
      }
      
      new PeriodicalExecuter(function(){
        new Ajax.JSONRequest(#{url}, {
          callbackParamName: 'callback',
          parameters: {
            format: 'json'
          },
          onSuccess: function(response){
            pipeline = response.responseJSON.pipelines[0]
            failed_stage = undefined
            $A(pipeline.stages).each(function(stage){
              if(isBuildFailed(stage)){
                failed_stage = stage
                throw $break
              }
            })
            if(!Object.isUndefined(failed_stage)){  
              if(Object.isUndefined(InputingContexts.top())){
                InputingContexts.push(new LightboxInputingContext(Prototype.emptyFunction))
                InputingContexts.top().update(getCruiseStatusReport())
              }
              content = generateLightBox(pipeline, failed_stage);
              InputingContexts.top().update('cruise_status_report', content);
            }
            else{
              if(!Object.isUndefined(InputingContexts.top())){
                InputingContexts.pop();
              }
            }
          },
        });
      }, #{interval});
      </script>
    HTML
  end
  
  def url
    final_url = (cruise_url<<'/' unless cruise_url.match(/\/$/)) || cruise_url
    final_url = final_url + "pipelineStatus.json?pipelineName=" + pipeline_name
    if cruise_authenticated?
      final_url = final_url.split("://").collect(&:to_json).join('+"://'+username+':'+password+'@"+')
    end
    final_url
  end
  
  def cruise_authenticated?
    'true'.eql?(@parameters['authenticate']||'true')
  end
  
  def interval
    @parameters["interval"] || @@DEFULT_INTERVAL
  end
  
  def self.default_interval
    @@DEFULT_INTERVAL
  end
  
  private  
  def username
    @parameters["username"]
  end
  
  def password
    @parameters["password"]
  end
  
  def pipeline_name
    @parameters["pipeline_name"]
  end
  
  def cruise_url
    @parameters["cruise_url"]
  end
    
end

