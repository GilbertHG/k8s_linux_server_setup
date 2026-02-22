#!/bin/bash

# Container names
MASTER="k8s-master"
WORKER1="k8s-worker1"
WORKER2="k8s-worker2"

# Expected IP addresses
MASTER_IP="172.20.0.10"
WORKER1_IP="172.20.0.11"
WORKER2_IP="172.20.0.12"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}→${NC} $1"
}

check_containers_running() {
    echo "=== Checking if containers are running ==="
    for container in $MASTER $WORKER1 $WORKER2; do
        if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
            print_success "$container is running"
        else
            print_error "$container is not running"
            exit 1
        fi
    done
    echo ""
}

verify_ip_addresses() {
    echo "=== Verifying IP Addresses ==="
    
    master_ip=$(docker exec $MASTER hostname -I | awk '{print $1}')
    worker1_ip=$(docker exec $WORKER1 hostname -I | awk '{print $1}')
    worker2_ip=$(docker exec $WORKER2 hostname -I | awk '{print $1}')
    
    if [ "$master_ip" = "$MASTER_IP" ]; then
        print_success "k8s-master has correct IP: $master_ip"
    else
        print_error "k8s-master IP mismatch. Expected: $MASTER_IP, Got: $master_ip"
    fi
    
    if [ "$worker1_ip" = "$WORKER1_IP" ]; then
        print_success "k8s-worker1 has correct IP: $worker1_ip"
    else
        print_error "k8s-worker1 IP mismatch. Expected: $WORKER1_IP, Got: $worker1_ip"
    fi
    
    if [ "$worker2_ip" = "$WORKER2_IP" ]; then
        print_success "k8s-worker2 has correct IP: $worker2_ip"
    else
        print_error "k8s-worker2 IP mismatch. Expected: $WORKER2_IP, Got: $worker2_ip"
    fi
    echo ""
}

test_connectivity() {
    echo "=== Testing Network Connectivity ==="
    
    test_ping() {
        local from=$1
        local to=$2
        local to_ip=$3
        
        print_info "Testing $from → $to ($to_ip)"
        if docker exec $from ping -c 2 -W 1 $to_ip > /dev/null 2>&1; then
            print_success "$from can reach $to"
        else
            print_error "$from cannot reach $to"
        fi
    }
    
    test_ping $MASTER $WORKER1 $WORKER1_IP
    test_ping $MASTER $WORKER2 $WORKER2_IP
    test_ping $WORKER1 $MASTER $MASTER_IP
    test_ping $WORKER1 $WORKER2 $WORKER2_IP
    test_ping $WORKER2 $MASTER $MASTER_IP
    test_ping $WORKER2 $WORKER1 $WORKER1_IP
    echo ""
}

main() {
    echo "=========================================="
    echo "  K8s Docker Network Validation Script"
    echo "=========================================="
    echo ""
    
    check_containers_running
    verify_ip_addresses
    test_connectivity
    
    echo "=========================================="
    echo "  Validation Complete"
    echo "=========================================="
}

# Run main function
main