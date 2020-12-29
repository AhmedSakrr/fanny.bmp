##
# This module requires Metasploit: https://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

class MetasploitModule < Msf::Post
  include Msf::Post::Common
  include Msf::Post::Windows::Registry
  include Msf::Auxiliary::Report

  def initialize(info = {})
    super(
      update_info(
        info,
        'Name' => 'FannyBMP or Dementiawheel Detection Registry Check',
        'Description' => %q{
          This module searches for the Fanny.bmp worm related reg keys.
          fannybmp is a worm that exploited zero day vulns.
          (more specifically, the LNK Exploit CVE-2010-2568).
          Which allowed it to spread even if USB Autorun was turned off.
          This is exactly the same Exploit that was used in StuxNet.
        },
        'License' => MSF_LICENSE,
        'Author' => ['William M.'],
        'Platform' => ['win'],
        'SessionTypes' => ['meterpreter', 'shell'],
        'References' =>
        [
          ['URL', 'https://securelist.com/a-fanny-equation-i-am-your-father-stuxnet/68787'],
          ['CVE', '2010-2568']
        ]
      )
    )
  end

  def run

    artifacts =
      [
        'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\MediaResources\"acm"',
        'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\MediaResources\acm\ECELP4',
        'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\MediaResources\acm\ECELP4\Driver',
        'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\MediaResources\acm\ECELP4\filter2',
        'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\MediaResources\acm\ECELP4\filter3',
        'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\MediaResources\acm\ECELP4\filter8'
      ]

    match = 0

    print('Searching registry on Target for Fanny.bmp artifacts.')

    begin
      artifacts.each do |key|
        (key, value) = parse_artifacts(key)
        has_key = registry_enumkeys(key)
        has_val = registry_enumvals(key)

        next unless has_key.include?(value) || has_val.include?(value)

        print_good("Target #{key}\\#{value} found in registry.")
        match += 1

        report_vuln(
          host: session.session_host,
          name: name,
          info: "Target #{key}\\#{value} found in registry.",
          refs: references,
          exploited_at: Time.now.utc
        )
      end
    end
    print_status('Done.')
  end

  def parse_artifacts(key)
    path = key.split('\\')
    value = path[-1]
    path.pop
    key = path.join('\\')
    [key, value]
  end
end
