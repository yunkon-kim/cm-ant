package spider

import (
	"errors"
	"fmt"
	"net/http"

	"github.com/cloud-barista/cm-ant/pkg/configuration"
)

var errorSubsystemInternal = errors.New("response status got error")

func SpiderHostWithPort() string {
	config := configuration.Get().Spider
	return fmt.Sprintf("%s:%s", config.Host, config.Port)
}

func responseStatus(res *http.Response) error {
	if res.StatusCode >= http.StatusInternalServerError {
		return errorSubsystemInternal
	}

	return nil
}
