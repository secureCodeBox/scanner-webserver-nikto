require 'json'
require 'ruby-scanner-scaffolding'

require_relative "./nikto_scan"
require_relative "./nikto_configuration"

class NiktoWorker < CamundaWorker
	def work(job_id, targets)
		configs = targets.map {|process_target|
			config = NiktoConfiguration.new
			config.nikto_target = process_target.dig('location')
			config.nikto_ports = process_target.dig('attributes', 'NIKTO_PORTS')
			config.nikto_parameter = process_target.dig('attributes', 'NIKTO_PARAMETER')
			config
		}

		scans = configs.map {|config|
			scan = NiktoScan.new(job_id, config)
			scan.start
			scan
		}

		{
			findings: scans.flat_map {|scan| scan.results},
			rawFindings: scans.map {|scan| scan.raw_results}.join(","),
			scannerId: @worker_id.to_s,
			scannerType: 'nikto'
		}
	end

	def healthy?
		if (self.last_connect != "ERROR" && scanner_test)
			return "UP"
		end
		return "DOWN"
	end

	def scanner_test
		system('perl /sectools/nikto-master/program/nikto.pl -Version > /dev/null')
		$? == 0
	end
end
