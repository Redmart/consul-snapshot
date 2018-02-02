package consul

import (
	"log"
	"strings"

	consulapi "github.com/hashicorp/consul/api"
)

// Consul struct is used for consul client such as the client
// and the actual key data.
type Consul struct {
	Client       consulapi.Client
	KeyData      consulapi.KVPairs
	KeyDataLen   int
	PQData       []*consulapi.PreparedQueryDefinition
	PQDataLen    int
	ACLData      []*consulapi.ACLEntry
	ACLDataLen   int
	ServicesData map[string][]*consulapi.CatalogService
}

// Client creates a consul client from the consul api
func Client() *consulapi.Client {
	consul, err := consulapi.NewClient(consulapi.DefaultConfig())
	if err != nil {
		log.Fatalf("[ERR] Unable to create a consul client: %v", err)
	}
	return consul
}

// ListKeys lists all the keys from consul with no prefix.
func (c *Consul) ListKeys() {
	listOpt := &consulapi.QueryOptions{
		AllowStale:        false,
		RequireConsistent: true,
	}
	keys, _, err := c.Client.KV().List("/", listOpt)
	if err != nil {
		log.Fatalf("[ERR] Unable to list keys: %v", err)
	}
	c.KeyData = keys
	c.KeyDataLen = len(keys)
}

// ListPQs lists all the prepared queries from consul
func (c *Consul) ListPQs() {
	listOpt := &consulapi.QueryOptions{
		AllowStale:        false,
		RequireConsistent: true,
	}
	pqs, _, err := c.Client.PreparedQuery().List(listOpt)
	if err != nil {
		log.Fatalf("[ERR] Unable to list PQs: %v", err)
	}

	c.PQData = pqs
	c.PQDataLen = len(pqs)
}

// ListACLs lists all the prepared queries from consul
func (c *Consul) ListACLs() {
	listOpt := &consulapi.QueryOptions{
		AllowStale:        false,
		RequireConsistent: true,
	}

	acls, _, err := c.Client.ACL().List(listOpt)
	if err != nil {
		// Really don't like this but seems to be the only way to detect
		if strings.Contains(err.Error(), "401 (ACL support disabled)") {
			log.Print("[INFO] ACL support detected as disbaled, skipping")
			c.ACLData = []*consulapi.ACLEntry{}
			c.ACLDataLen = 0
		} else {
			log.Fatalf("[ERR] Unable to list ACLs: %v", err)
		}
	} else {
		c.ACLData = acls
		c.ACLDataLen = len(acls)
	}
}

// ListServices lists all the catalog services from consul
func (c *Consul) ListServices() map[string][]string {
	listOpt := &consulapi.QueryOptions{
		AllowStale:        false,
		RequireConsistent: true,
	}

	services, _, err := c.Client.Catalog().Services(listOpt)
	if err != nil {
		log.Fatalf("[ERR] Unable to list keys: %v", err)
	}
	return services
}

// GetServicesData lists all the catalog services information from consul
func (c *Consul) GetServicesData() {
	listOpt := &consulapi.QueryOptions{
		AllowStale:        false,
		RequireConsistent: true,
	}
	c.ServicesData = make(map[string][]*consulapi.CatalogService)
	services := c.ListServices()

	for servicename := range services {
		servicedata, _, err := c.Client.Catalog().Service(servicename, "", listOpt)
		if err != nil {
			log.Fatalf("[ERR] Unable to list Service data: %v", err)
		}
		c.ServicesData[servicename] = servicedata
	}
}
