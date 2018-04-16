require 'json'

require_relative "../lib/camunda_worker"

require_relative "./nikto_scan"
require_relative "./nikto_configuration"

class NiktoWorker < CamundaWorker
  def work(task)

    config = NiktoConfiguration.new
    config.nikto_target = task.dig('variables', 'NIKTO_TARGET', 'value')
    config.nikto_ports = task.dig('variables', 'NIKTO_PORTS', 'value')
    config.nikto_parameter = task.dig('variables', 'NIKTO_PARAMETER', 'value')

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