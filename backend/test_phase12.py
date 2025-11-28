"""
Phase 12: External Application Integration System - Testing
"""

import sys
import os

# Add backend to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

def test_imports():
    """Test all imports"""
    print("\n=== Testing Imports ===")
    
    try:
        from app.models.external_app import (
            ExternalApplication, APIKey, ExternalAppUser,
            ExternalAppUsage, ExternalAppPricing
        )
        print("[OK] Models imported successfully")
    except Exception as e:
        print(f"[ERROR] Models import failed: {e}")
        return False
    
    try:
        from app.schemas.external_app import (
            ExternalApplicationCreate, ExternalApplicationResponse,
            APIKeyCreate, APIKeyResponse
        )
        print("[OK] Schemas imported successfully")
    except Exception as e:
        print(f"[ERROR] Schemas import failed: {e}")
        return False
    
    try:
        from app.services.external_app_service import ExternalAppService
        print("[OK] Service imported successfully")
    except Exception as e:
        print(f"[ERROR] Service import failed: {e}")
        return False
    
    try:
        from app.routers.external_app import router
        print("[OK] Router imported successfully")
    except Exception as e:
        print(f"[ERROR] Router import failed: {e}")
        return False
    
    return True


def test_compilation():
    """Test Python file compilation"""
    print("\n=== Testing Compilation ===")
    
    files = [
        "app/models/external_app.py",
        "app/schemas/external_app.py",
        "app/services/external_app_service.py",
        "app/routers/external_app.py"
    ]
    
    import py_compile
    
    for file in files:
        try:
            py_compile.compile(file, doraise=True)
            print(f"[OK] {file} compiled successfully")
        except py_compile.PyCompileError as e:
            print(f"[ERROR] {file} compilation failed: {e}")
            return False
    
    return True


def main():
    """Run all tests"""
    print("=" * 60)
    print("Phase 12: External Application Integration System - Testing")
    print("=" * 60)
    
    # Get backend directory
    backend_dir = os.path.dirname(os.path.abspath(__file__))
    if os.path.basename(backend_dir) == "backend":
        pass
    else:
        backend_dir = os.path.join(os.path.dirname(backend_dir), "backend")
    
    os.chdir(backend_dir)
    
    # Run tests
    tests = [
        ("Imports", test_imports),
        ("Compilation", test_compilation),
    ]
    
    results = []
    for test_name, test_func in tests:
        try:
            result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"[ERROR] {test_name} test failed with exception: {e}")
            results.append((test_name, False))
    
    # Summary
    print("\n" + "=" * 60)
    print("Test Summary")
    print("=" * 60)
    
    all_passed = True
    for test_name, result in results:
        status = "[PASS]" if result else "[FAIL]"
        print(f"{status} {test_name}")
        if not result:
            all_passed = False
    
    print("=" * 60)
    if all_passed:
        print("[SUCCESS] All tests passed!")
        return 0
    else:
        print("[FAILURE] Some tests failed!")
        return 1


if __name__ == "__main__":
    sys.exit(main())

