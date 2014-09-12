zabbix-api
==========

perl zabbix bindings

## Api usage

First create a ZabbixApi Object:

```perl
use ZabbixApi;

my $zabbix = ZabbixApi->new(
    user => 'winston',
    pw   => 'gayhaim69',
    url  => 'http://my.domain.com/api_jsonrpc.php',
);
```

Now you can use the zabbix api described in the documentation like this.
Let us first get the hostgroup id of `Linux servers`.

```perl
# set api method
$zabbix->set_method('hostgroup.get');

# wrapper around output: set to 'extend'
$zabbix->payload->set_output(3);

# perform api call
$zabbix->process;

# find the Object describing Linux servers group
my $o = $zabbix->find_by( 'name', 'Linux servers' );

# we got a hash
my $id = $$o{'groupid'};

# clear the api buffer before the next action

$zabbix->clear;

```

Now we can create a host that is in this hostgroup

```perl
# set api method
$zabbix->set_method('host.create');

# add the new hostgroup
$zabbix->add_params( { groups => [ { 'groupid' => $id } ] } );

# add the interfaces
$zabbix->add_params(
    {
        interfaces =>
        [
            {
                 'useip' => 1,
                 'ip'    => '188.187.123.123',
                 'port'  => '10050',
                 'dns'   => 'test.com',
                 'type'  => 1,
                 'main'  => 1,
            }
        ]
    }
);

# add the new hostname
$zabbix->add_params( { 'host' => 'testhost' } );

# perform the api call which creates the hostgroup
$zabbix->process;
```
Of course you can add all the params in one `add_params` call. It takes every hash ref as an argument.


## Modules you may need

- Moo.pm and JSON.pm
On debian: apt-get install libmoo-perl libjson-perl

