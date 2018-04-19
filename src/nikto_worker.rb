require 'json'

require_relative "../lib/camunda_worker"

require_relative "./nikto_scan"
require_relative "./nikto_configuration"

class NiktoWorker < CamundaWorker
  def work(task)

    # Quite Ugly isn't it?
    process_targets = task.dig('variables', 'PROCESS_TARGETS', 'value')
    process_targets[0]=""
    process_targets[process_targets.length-1]=""
    process_targets.gsub!('\\','')
    process_targets = JSON.parse(process_targets)

    config = NiktoConfiguration.new
    config.nikto_target = process_targets[0].dig('location')
    config.nikto_ports = process_targets[0].dig('attributes', 'NIKTO_PORTS')
    config.nikto_parameter = process_targets[0].dig('attributes', 'NIKTO_PARAMETER')

    scan = NiktoScan.new(task.dig('id'), config)
    scan.start

    {
        PROCESS_FINDINGS: {
            value: scan.results.to_json,
            type: 'Object',
            valueInfo: {
                objectTypeName: 'java.lang.String',
                serializationDataFormat: 'application/json',
            },
        },
        PROCESS_RAW_FINDINGS: {
            value: scan.raw_results.to_json,
            type: 'Object',
            valueInfo: {
                objectTypeName: 'java.lang.String',
                serializationDataFormat: 'application/json',
            },
        },
        PROCESS_SCANNER_ID: {
            value: @worker_id.to_s,
            type: 'String'
        },
        PROCESS_SCANNER_TYPE: {
            value: 'nikto',
            type: 'String'
        }
    }
  end
end
