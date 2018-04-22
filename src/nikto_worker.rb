require 'json'

require_relative "../lib/camunda_worker"

require_relative "./nikto_scan"
require_relative "./nikto_configuration"

class NiktoWorker < CamundaWorker
  def work(job_id, targets)
    config = NiktoConfiguration.new
    config.nikto_target = targets[0].dig('location')
    config.nikto_ports = targets[0].dig('attributes', 'NIKTO_PORTS')
    config.nikto_parameter = targets[0].dig('attributes', 'NIKTO_PARAMETER')

    scan = NiktoScan.new(job_id, config)
    scan.start

    {
        findings: scan.results,
        raw_findings: scan.raw_results,
        scannerId: @worker_id.to_s,
        scannerType: 'nikto'
    }
  end
end
