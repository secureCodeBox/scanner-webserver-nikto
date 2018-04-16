require 'json'
require 'rest-client'
require 'securerandom'
require 'logger'

$logger = Logger.new(STDOUT)

if ENV.key? 'DEBUG'
  $logger.level = Logger::DEBUG
  STDOUT.sync = ENV['DEBUG']
else
  $logger.level = Logger::INFO
end

class CamundaWorker
  attr_reader :worker_id
  attr_reader :started_tasks
  attr_reader :completed_tasks
  attr_reader :failed_tasks

  def initialize(camunda_url, topic, variables, task_lock_duration = 3600000, poll_interval = 5)
    @camunda_url = ENV.fetch('ENGINE_ADDRESS', camunda_url)
    @topic, @variables, @task_lock_duration = topic, variables, task_lock_duration
    @worker_id = SecureRandom.uuid
    @started_tasks, @completed_tasks, @failed_tasks = 0, 0, 0

    @protected_engine = (ENV.has_key? 'ENGINE_BASIC_AUTH_USER') and (ENV.has_key? 'ENGINE_BASIC_AUTH_PASSWORD')
    @basic_auth_user = ENV.fetch('ENGINE_BASIC_AUTH_USER', '')
    @basic_auth_password = ENV.fetch('ENGINE_BASIC_AUTH_PASSWORD', '')

    Thread.new do
      sleep poll_interval

      loop do
        begin
          $logger.debug('Getting new scans')
          tick
          $logger.debug("Sleeping for #{poll_interval}...")
        rescue => err
          $logger.warn err
        end

        sleep poll_interval
      end
    end
  end

  def tick
    tasks = fetch_and_lock_task

    unless tasks.empty?
      @started_tasks = @started_tasks.succ

      task = tasks[0]

      $logger.info "Started scan #{task.dig('id')}"

      begin
        result = self.work(tasks[0])

        @completed_tasks = @completed_tasks.succ

        self.complete_task task.dig('id'), result

        $logger.info "Completed scan #{task.dig('id')}"
      rescue => err
        $logger.warn "Failed to perform scan #{task.dig('id')}"
        $logger.warn err
        $logger.warn "Task will be unlocked for further tries."

        @failed_tasks = @failed_tasks.succ

        self.fail_task task.dig('id')
      end
    end
  end

  def work(task)
    $logger.error "You should override the work method of the CamundaWorker with a proper implementation!"
  end

  def fetch_and_lock_task
    $logger.debug "fetching task"

    payload = {
        workerId: @worker_id,
        maxTasks: 1,
        topics: [
            {
                topicName: @topic,
                variables: @variables,
                lockDuration: @task_lock_duration
            }
        ]
    }

    $logger.debug "#{@camunda_url}/external-task/fetchAndLock"
    $logger.debug payload.to_json

    JSON.parse(self.http_post("#{@camunda_url}/external-task/fetchAndLock", payload.to_json))
  end

  def fail_task(task_id)
    result = self.http_post("#{@camunda_url}/external-task/#{task_id}/unlock")
    $logger.debug "unlocked task: " + result.to_str
    result
  end

  def complete_task(task_id, variables)
    payload = {
        workerId: @worker_id,
        variables: variables
    }

    $logger.debug "completing task: #{payload.to_json}"

    result = self.http_post("#{@camunda_url}/external-task/#{task_id}/complete", payload.to_json)
    $logger.debug "completed task: #{result.to_str}"
    result
  end


  def http_post(url, payload = "")
    request = self.create_post_request(url, payload)

    begin
      request.execute do |response, request, result|
        case response.code
        when 200
          $logger.debug 'success ' + response.code.to_s
          return response
        when 204
          $logger.debug 'success ' + response.code.to_s
          return ''
        else
          $logger.debug "Invalid response #{response.to_str} received."
          fail "Code #{response.code}: Invalid response #{response.to_str} received."
        end
      end
    rescue => e
      $logger.debug "Error while connecting to #{url}"
      $logger.debug e.message
      return nil
    end
  end

  def create_post_request(url, payload)
    if @protected_engine
      RestClient::Request.new({
          method: :post,
          url: url,
          user: @basic_auth_user,
          password: @basic_auth_password,
          payload: payload,
          headers: {:accept => :'application/json', content_type: :'application/json'}
      })
    else
      RestClient::Request.new({
          method: :post,
          url: url,
          payload: payload,
          headers: {:accept => :'application/json', content_type: :'application/json'}
      })
    end
  end
end