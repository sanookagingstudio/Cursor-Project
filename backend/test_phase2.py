"""
Phase 2: Input Brain Module - Test Script
Tests all API endpoints and functionality
"""

import requests
import json
from typing import Dict, Any

BASE_URL = "http://localhost:8000/api/input-brain"

def print_section(title: str):
    """Print section header"""
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}")

def test_create_idea() -> Dict[str, Any]:
    """Test creating a content idea"""
    print_section("Test 1: Create Content Idea")
    
    data = {
        "type": "image",
        "prompt": "A cute cat playing with yarn in a sunny garden",
        "options": {}
    }
    
    try:
        response = requests.post(f"{BASE_URL}/ideas", json=data)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 201:
            result = response.json()
            print(f"[OK] Idea created: {result['id']}")
            print(f"     Type: {result['type']}")
            print(f"     Status: {result['status']}")
            return result
        else:
            print(f"[ERROR] Failed: {response.text}")
            return {}
    except Exception as e:
        print(f"[ERROR] Exception: {str(e)}")
        return {}

def test_get_idea(idea_id: str):
    """Test getting an idea by ID"""
    print_section("Test 2: Get Content Idea")
    
    try:
        response = requests.get(f"{BASE_URL}/ideas/{idea_id}")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"[OK] Idea retrieved: {result['id']}")
            print(f"     Prompt: {result['prompt'][:50]}...")
            return result
        else:
            print(f"[ERROR] Failed: {response.text}")
            return {}
    except Exception as e:
        print(f"[ERROR] Exception: {str(e)}")
        return {}

def test_generate_suggestions(idea_id: str):
    """Test generating AI suggestions"""
    print_section("Test 3: Generate AI Suggestions")
    
    try:
        response = requests.post(f"{BASE_URL}/ideas/{idea_id}/generate-suggestions?num_versions=4")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"[OK] Suggestions generated: {len(result['versions'])} versions")
            for i, version in enumerate(result['versions'], 1):
                print(f"     Version {i}: index={version['version_index']}, style={version['metadata'].get('style', 'N/A')}")
            return result
        else:
            print(f"[ERROR] Failed: {response.text}")
            return {}
    except Exception as e:
        print(f"[ERROR] Exception: {str(e)}")
        return {}

def test_select_version(idea_id: str, version_index: int):
    """Test selecting a version"""
    print_section("Test 4: Select Version")
    
    try:
        response = requests.post(f"{BASE_URL}/ideas/{idea_id}/select-version?version_index={version_index}")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"[OK] Version {version_index} selected")
            print(f"     Status: {result['status']}")
            return result
        else:
            print(f"[ERROR] Failed: {response.text}")
            return {}
    except Exception as e:
        print(f"[ERROR] Exception: {str(e)}")
        return {}

def test_get_versions(idea_id: str):
    """Test getting all versions"""
    print_section("Test 5: Get All Versions")
    
    try:
        response = requests.get(f"{BASE_URL}/ideas/{idea_id}/versions")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"[OK] Retrieved {len(result)} versions")
            return result
        else:
            print(f"[ERROR] Failed: {response.text}")
            return {}
    except Exception as e:
        print(f"[ERROR] Exception: {str(e)}")
        return {}

def test_generate_workflow_draft(idea_id: str, version_index: int):
    """Test generating workflow draft"""
    print_section("Test 6: Generate Workflow Draft")
    
    try:
        response = requests.post(f"{BASE_URL}/ideas/{idea_id}/generate-workflow-draft?version_index={version_index}")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"[OK] Workflow draft created: {result['id']}")
            print(f"     Steps: {len(result['steps'])}")
            for i, step in enumerate(result['steps'], 1):
                print(f"     Step {i}: {step['module']}.{step['action']}")
            return result
        else:
            print(f"[ERROR] Failed: {response.text}")
            return {}
    except Exception as e:
        print(f"[ERROR] Exception: {str(e)}")
        return {}

def test_get_workflow_draft(draft_id: str):
    """Test getting workflow draft"""
    print_section("Test 7: Get Workflow Draft")
    
    try:
        response = requests.get(f"{BASE_URL}/workflow-drafts/{draft_id}")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"[OK] Workflow draft retrieved: {result['id']}")
            print(f"     Status: {result['status']}")
            return result
        else:
            print(f"[ERROR] Failed: {response.text}")
            return {}
    except Exception as e:
        print(f"[ERROR] Exception: {str(e)}")
        return {}

def test_start_workflow(draft_id: str):
    """Test starting workflow"""
    print_section("Test 8: Start Workflow")
    
    try:
        response = requests.post(f"{BASE_URL}/workflow-drafts/{draft_id}/start")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"[OK] Workflow started")
            print(f"     Status: {result.get('status', 'N/A')}")
            return result
        else:
            print(f"[ERROR] Failed: {response.text}")
            return {}
    except Exception as e:
        print(f"[ERROR] Exception: {str(e)}")
        return {}

def main():
    """Run all tests"""
    print("\n" + "="*60)
    print("  Phase 2: Input Brain Module - API Tests")
    print("="*60)
    
    # Test 1: Create idea
    idea = test_create_idea()
    if not idea or 'id' not in idea:
        print("\n[ERROR] Cannot continue without idea ID")
        return
    
    idea_id = idea['id']
    
    # Test 2: Get idea
    test_get_idea(idea_id)
    
    # Test 3: Generate suggestions
    suggestions = test_generate_suggestions(idea_id)
    if not suggestions or 'versions' not in suggestions or len(suggestions['versions']) == 0:
        print("\n[ERROR] Cannot continue without versions")
        return
    
    version_index = suggestions['versions'][0]['version_index']
    
    # Test 4: Select version
    test_select_version(idea_id, version_index)
    
    # Test 5: Get versions
    test_get_versions(idea_id)
    
    # Test 6: Generate workflow draft
    draft = test_generate_workflow_draft(idea_id, version_index)
    if not draft or 'id' not in draft:
        print("\n[ERROR] Cannot continue without draft ID")
        return
    
    draft_id = draft['id']
    
    # Test 7: Get workflow draft
    test_get_workflow_draft(draft_id)
    
    # Test 8: Start workflow
    test_start_workflow(draft_id)
    
    # Summary
    print_section("Test Summary")
    print("[OK] All tests completed!")
    print(f"     Idea ID: {idea_id}")
    print(f"     Draft ID: {draft_id}")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n[INFO] Tests interrupted by user")
    except Exception as e:
        print(f"\n\n[ERROR] Unexpected error: {str(e)}")

