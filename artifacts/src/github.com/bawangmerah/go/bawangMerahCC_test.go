package bmcc_test

import (
	"testing"

	bm "github.com/mrifqip29/bm-network/artifacts/src/github.com/bawangmerah/go"

	"github.com/s7techlab/cckit/identity/testdata"
	//"github.com/s7techlab/cckit/state"
	testcc "github.com/s7techlab/cckit/testing"
	expectcc "github.com/s7techlab/cckit/testing/expect"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

func TestBawang(t *testing.T){
	RegisterFailHandler(Fail)
	RunSpecs(t, "Bawang Suite")
}

var (
	Authority = testdata.Certificates[0].MustIdentity(`SOME_MSP`)
	Someone   = testdata.Certificates[1].MustIdentity(`SOME_MSP`)
)

var _ = Describe(`BMCC`, func(){
	bawangCC := testcc.NewMockStub(
		// chaincode name
		`bawangmerah`,
		// chaincode implementation, supports Chaincode interface with Init and Invoke methods
		InitLedger(),
		)

	BeforeSuite(func() {
		// init chaincode
		expectcc.ResponseOk(bawangCC.From(Authority).InitLedger()) // init chaincode from authority
	})	

	Describe(`Bawang`, func() {
		It("Allow user to create benih asset", func() {
			//invoke chaincode method from non authority actor
			expectcc.ResponseOk(
				bawangCC.From(Authority).Invoke(`CreateBenih`, Payloads[0]))
		})
	})
})