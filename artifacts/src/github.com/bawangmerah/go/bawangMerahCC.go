package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"
	"time"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"github.com/hyperledger/fabric/common/flogging"
)

type SmartContract struct {
	contractapi.Contract
}

var logger = flogging.MustGetLogger("fabcar_cc")

type Car struct {
	ID      string `json:"id"`
	Make    string `json:"make"`
	Model   string `json:"model"`
	Colour  string `json:"colour"`
	Owner   string `json:"owner"`
	AddedAt uint64 `json:"addedAt"`
}

// Bawang object struct
type Bawang struct {
	ID string `json:"id"`

	UsernamePengirim string `json:"usernamePengirim"`
	UsernamePenerima string `json:"usernamePenerima"`
	AlamatPengirim   string `json:"alamatPengirim"`
	AlamatPenerima   string `json:"alamatPenerima"`

	Kuantitas string `json:"kuantitas"`
	Harga     string `json:"harga"`
	Timestamp int64  `json:"timestamp"`

	UmurBenih       string `json:"umurBenih"`
	UmurPanen       string `json:"umurPanen"`
	LamaPenyimpanan string `json:"lamaPenyimpanan"`
	Varietas        string `json:"varietas"`
	HargaBenih      string `json:"hargaBenih"`

	UkuranUmbi    string `json:"ukuranUmbi"`
	KadarAir      string `json:"kadarAir"`
	Pupuk         string `json:"pupuk"`
	Pestisida     string `json:"pestisida"`
	Perlakuan     string `json:"perlakuan"`
	Produktivitas string `json:"produktivitas"`

	TanggalMasuk     string `json:"tanggalMasuk"`
	AamatGudang      string `json:"alamatGudang"`
	TeknikSorting    string `json:"teknikSorting"`
	MetodePengemasan string `json:"metodePengemasan"`

	Status      string `json:"status"`
	TransaksiID string `json:"transaksiID"`
	BatchID     string `json:"batchID"`
	TxID        string `json:"txID"`
}

// CreateBawang function to create bawang asset and insert it on blockchain
func (s *SmartContract) CreateBawang(ctx contractapi.TransactionContextInterface, bawangData string) (string, error) {

	if len(bawangData) == 0 {
		return "", fmt.Errorf("Please pass the correct bawang data")
	}

	var bawang Bawang

	bawang.Timestamp = time.Now().Unix()

	bawang.TxID = ctx.GetStub().GetTxID()

	err := json.Unmarshal([]byte(bawangData), &bawang)
	if err != nil {
		return "", fmt.Errorf("Failed while unmarshling bawang. %s", err.Error())
	}

	bawangAsBytes, err := json.Marshal(bawang)
	if err != nil {
		return "", fmt.Errorf("Failed while marshling bawang. %s", err.Error())
	}

	// Insert into blockchain
	ctx.GetStub().SetEvent("CreateAsset", bawangAsBytes)

	// Put state using key and data
	return ctx.GetStub().GetTxID(), ctx.GetStub().PutState(bawang.ID, bawangAsBytes)
}

func (s *SmartContract) CreateCar(ctx contractapi.TransactionContextInterface, carData string) (string, error) {

	if len(carData) == 0 {
		return "", fmt.Errorf("Please pass the correct car data")
	}

	var car Car
	err := json.Unmarshal([]byte(carData), &car)
	if err != nil {
		return "", fmt.Errorf("Failed while unmarshling car. %s", err.Error())
	}

	carAsBytes, err := json.Marshal(car)
	if err != nil {
		return "", fmt.Errorf("Failed while marshling car. %s", err.Error())
	}

	ctx.GetStub().SetEvent("CreateAsset", carAsBytes)

	return ctx.GetStub().GetTxID(), ctx.GetStub().PutState(car.ID, carAsBytes)
}

// UpdateBawangOwnerByID function the update the UsernamePengirim, UsernamePenerima, AlamatPengirim, and AlamatPenerima by ID
func (s *SmartContract) UpdateBawangOwnerByID(ctx contractapi.TransactionContextInterface, bawangID string, NewUsernamePengirim string,
	NewUsernamePenerima string, NewAlamatPengirim string, NewAlamatPenerima string) (string, error) {

	if len(bawangID) == 0 {
		return "", fmt.Errorf("Please pass the correct bawang id")
	}

	bawangAsBytes, err := ctx.GetStub().GetState(bawangID)

	if err != nil {
		return "", fmt.Errorf("Failed to get bawang data. %s", err.Error())
	}

	if bawangAsBytes == nil {
		return "", fmt.Errorf("%s does not exist", bawangID)
	}

	// Create new bawang object
	bawang := new(Bawang)
	_ = json.Unmarshal(bawangAsBytes, bawang)

	// Change the owner
	bawang.UsernamePengirim = NewUsernamePengirim
	bawang.UsernamePenerima = NewUsernamePenerima
	bawang.AlamatPengirim = NewAlamatPengirim
	bawang.AlamatPenerima = NewAlamatPenerima

	bawangAsBytes, err = json.Marshal(bawang)
	if err != nil {
		return "", fmt.Errorf("Failed while marshling car. %s", err.Error())
	}

	//  txId := ctx.GetStub().GetTxID()

	// Update the state
	return ctx.GetStub().GetTxID(), ctx.GetStub().PutState(bawang.ID, bawangAsBytes)
}

func (s *SmartContract) UpdateCarOwner(ctx contractapi.TransactionContextInterface, carID string, newOwner string) (string, error) {

	if len(carID) == 0 {
		return "", fmt.Errorf("Please pass the correct car id")
	}

	carAsBytes, err := ctx.GetStub().GetState(carID)

	if err != nil {
		return "", fmt.Errorf("Failed to get car data. %s", err.Error())
	}

	if carAsBytes == nil {
		return "", fmt.Errorf("%s does not exist", carID)
	}

	car := new(Car)
	_ = json.Unmarshal(carAsBytes, car)

	car.Owner = newOwner

	carAsBytes, err = json.Marshal(car)
	if err != nil {
		return "", fmt.Errorf("Failed while marshling car. %s", err.Error())
	}

	//  txId := ctx.GetStub().GetTxID()

	return ctx.GetStub().GetTxID(), ctx.GetStub().PutState(car.ID, carAsBytes)

}

// GetHistoryForAssetByID to get history for asset by ID
func (s *SmartContract) GetHistoryForAssetByID(ctx contractapi.TransactionContextInterface, bawangID string) (string, error) {

	resultsIterator, err := ctx.GetStub().GetHistoryForKey(bawangID)
	if err != nil {
		return "", fmt.Errorf(err.Error())
	}
	defer resultsIterator.Close()

	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return "", fmt.Errorf(err.Error())
		}
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"TxId\":")
		buffer.WriteString("\"")
		buffer.WriteString(response.TxId)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Value\":")
		if response.IsDelete {
			buffer.WriteString("null")
		} else {
			buffer.WriteString(string(response.Value))
		}

		buffer.WriteString(", \"Timestamp\":")
		buffer.WriteString("\"")
		buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
		buffer.WriteString("\"")

		buffer.WriteString(", \"IsDelete\":")
		buffer.WriteString("\"")
		buffer.WriteString(strconv.FormatBool(response.IsDelete))
		buffer.WriteString("\"")

		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	return string(buffer.Bytes()), nil
}

func (s *SmartContract) GetHistoryForAsset(ctx contractapi.TransactionContextInterface, carID string) (string, error) {

	resultsIterator, err := ctx.GetStub().GetHistoryForKey(carID)
	if err != nil {
		return "", fmt.Errorf(err.Error())
	}
	defer resultsIterator.Close()

	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return "", fmt.Errorf(err.Error())
		}
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"TxId\":")
		buffer.WriteString("\"")
		buffer.WriteString(response.TxId)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Value\":")
		if response.IsDelete {
			buffer.WriteString("null")
		} else {
			buffer.WriteString(string(response.Value))
		}

		buffer.WriteString(", \"Timestamp\":")
		buffer.WriteString("\"")
		buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
		buffer.WriteString("\"")

		buffer.WriteString(", \"IsDelete\":")
		buffer.WriteString("\"")
		buffer.WriteString(strconv.FormatBool(response.IsDelete))
		buffer.WriteString("\"")

		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	return string(buffer.Bytes()), nil
}

// GetBawangByID get car object by ID
func (s *SmartContract) GetBawangByID(ctx contractapi.TransactionContextInterface, bawangID string) (*Bawang, error) {
	if len(bawangID) == 0 {
		return nil, fmt.Errorf("Please provide correct contract ID")
		// return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	// fetch bawang by its ID
	bawangAsBytes, err := ctx.GetStub().GetState(bawangID)

	if err != nil {
		return nil, fmt.Errorf("Failed to read from world state. %s", err.Error())
	}

	if bawangAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", bawangID)
	}

	// create new Bawang object and unmarshal bawangAsBytes into bawang
	bawang := new(Bawang)
	_ = json.Unmarshal(bawangAsBytes, bawang)

	return bawang, nil
}

func (s *SmartContract) GetCarById(ctx contractapi.TransactionContextInterface, carID string) (*Car, error) {
	if len(carID) == 0 {
		return nil, fmt.Errorf("Please provide correct contract Id")
		// return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	carAsBytes, err := ctx.GetStub().GetState(carID)

	if err != nil {
		return nil, fmt.Errorf("Failed to read from world state. %s", err.Error())
	}

	if carAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", carID)
	}

	car := new(Car)
	_ = json.Unmarshal(carAsBytes, car)

	return car, nil

}

func (s *SmartContract) GetContractsForQuery(ctx contractapi.TransactionContextInterface, queryString string) ([]Bawang, error) {

	queryResults, err := s.getQueryResultForQueryString(ctx, queryString)

	if err != nil {
		return nil, fmt.Errorf("Failed to read from ----world state. %s", err.Error())
	}

	return queryResults, nil

}

func (s *SmartContract) getQueryResultForQueryString(ctx contractapi.TransactionContextInterface, queryString string) ([]Bawang, error) {

	resultsIterator, err := ctx.GetStub().GetQueryResult(queryString)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	results := []Bawang{}

	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}

		newBawang := new(Bawang)

		err = json.Unmarshal(response.Value, newBawang)
		if err != nil {
			return nil, err
		}

		results = append(results, *newBawang)
	}
	return results, nil
}

func (s *SmartContract) GetDocumentUsingCarContract(ctx contractapi.TransactionContextInterface, documentID string) (string, error) {
	if len(documentID) == 0 {
		return "", fmt.Errorf("Please provide correct contract Id")
	}

	params := []string{"GetDocumentById", documentID}
	queryArgs := make([][]byte, len(params))
	for i, arg := range params {
		queryArgs[i] = []byte(arg)
	}

	response := ctx.GetStub().InvokeChaincode("document_cc", queryArgs, "mychannel")

	return string(response.Payload), nil

}

func (s *SmartContract) CreateDocumentUsingCarContract(ctx contractapi.TransactionContextInterface, functionName string, documentData string) (string, error) {
	if len(documentData) == 0 {
		return "", fmt.Errorf("Please provide correct document data")
	}

	params := []string{functionName, documentData}
	queryArgs := make([][]byte, len(params))
	for i, arg := range params {
		queryArgs[i] = []byte(arg)
	}

	response := ctx.GetStub().InvokeChaincode("document_cc", queryArgs, "mychannel")

	return string(response.Payload), nil

}

func main() {

	chaincode, err := contractapi.NewChaincode(new(SmartContract))
	if err != nil {
		fmt.Printf("Error create fabcar chaincode: %s", err.Error())
		return
	}
	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting chaincodes: %s", err.Error())
	}

}
