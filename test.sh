docker build -q -t xri .
docker run --rm --name xri -d -p 8080:8080 xri

RESULT=`curl -s --header "Content-Type: application/json" \
  --request POST \
  --data '{"id":"abcd", "opcode":128,"state":{"a":59,"b":1,"c":0,"d":5,"e":15,"h":10,"l":20,"flags":{"sign":false,"zero":false,"auxCarry":true,"parity":false,"carry":true},"programCounter":1,"stackPointer":2,"cycles":0,"interruptsEnabled":true}}' \
  http://localhost:8080/api/v1/execute?operand1=129`
EXPECTED='{"id":"abcd", "opcode":128,"state":{"a":186,"b":1,"c":0,"d":5,"e":15,"h":10,"l":20,"flags":{"sign":true,"zero":false,"auxCarry":false,"parity":false,"carry":false},"programCounter":1,"stackPointer":2,"cycles":7,"interruptsEnabled":true}}'

docker kill xri

DIFF=`diff <(jq -S . <<< "$RESULT") <(jq -S . <<< "$EXPECTED")`

if [ $? -eq 0 ]; then
    echo -e "\e[32mXRI Test Pass \e[0m"
    exit 0
else
    echo -e "\e[31mXRI Test Fail  \e[0m"
    echo "$RESULT"
    echo "$DIFF"
    exit -1
fi